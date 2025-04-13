# Server configurations for load testing

## Puma

Single worker thread configuration

```bash
puma -t 1:1 -p 3000
```

## Passenger

Start with max pool size of 1 worker

```bash
passenger start --max-pool-size 1
```

## Thin

Start in threaded mode with 2 worker threads

```bash
thin start --threaded --threadpool-size 2
```
