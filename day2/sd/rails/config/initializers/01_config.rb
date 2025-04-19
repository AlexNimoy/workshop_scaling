$current_ip = ENV.fetch('CURRENT_IP', '172.22.1.11')

Diplomat.configure do |config|
  config.url = "http://#{$current_ip}:8500"
end

class LeaderElector
  LEADER_KEY = 'service/leader'
  SESSION_TTL = '10s'
  
  def initialize
    @session_id = nil
  end

  def identifier
    $identifier ||= "#{ENV['HOSTNAME']}_#{Time.now.to_i}"
  end

  def create_session
    @session_id ||= Diplomat::Session.create({
      Name: identifier,
      TTL: SESSION_TTL,
      Behavior: 'delete'
    })
  end

  def renew_session
    Diplomat::Session.renew(@session_id) if @session_id
  rescue Diplomat::SessionNotFound
    @session_id = nil
  end

  def leader_identifier
    begin
      kv = Diplomat::Kv.get(LEADER_KEY, {}, :return)
      session = kv[1]['Session'] rescue nil
      return nil unless session
      
      value = kv[0]
      return value
    rescue Diplomat::KeyNotFound
      return nil
    end
  end

  def leader?
    # Try to renew our session if we have one
    renew_session if @session_id
    
    # Create a new session if needed
    create_session unless @session_id
    
    # Check if we are already the leader
    if (lid = leader_identifier)
      return lid == identifier
    end
    
    # Try to acquire the lock
    success = Diplomat::Kv.put(LEADER_KEY, identifier, { acquire: @session_id })
    
    return success && leader_identifier == identifier
  end
end

Rails.application.config.after_initialize do
  registry = Prometheus::Client.registry
  memory_gauge = registry.gauge(:rss_memory_bytes, docstring: 'RSS memory in bytes')
  memory_gauge_mb = registry.gauge(:rss_memory_mb, docstring: 'RSS memory in MB')

  cpu_usage_gauge = registry.gauge(:process_cpu_usage_percent, docstring: 'CPU usage in percent')

  total_database_count = registry.gauge(:total_records, docstring: 'total records in DB')

  elector = LeaderElector.new

  ActiveSupport::Notifications.subscribe('metrics.before_scrape') do
    bytes = GetProcessMem.new.bytes
    mb = bytes / 1024 / 1024
    memory_gauge.set(bytes)
    memory_gauge_mb.set(mb)

    if elector.leader?
      total_database_count.set(100)
    end

    cpu_usage = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID) / Process.clock_gettime(Process::CLOCK_MONOTONIC) * 100
    cpu_usage_gauge.set(cpu_usage)
  end
end
