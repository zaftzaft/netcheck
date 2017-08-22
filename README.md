netcheck
=========

Network check script for Prometheus


## Depends
- Node.js
- npm
- Optional
  - dig
  - ping
  - curl
  - arping


## Installation
```console
$ git clone https://github.com/zaftzaft/netcheck.git
$ cd netcheck
$ sudo sh install.sh # install & enable systemd
$ curl localhost:9059/metrics?config=default
netcheck_ping{addr="8.8.8.8",status="result"} 1
netcheck_ping{addr="8.8.8.8",status="rtt"} 2.34
netcheck_dns{addr="google.com",status="result",nameserver="8.8.8.8"} 1
netcheck_http{addr="google.com",status="result"} 1
netcheck_http{addr="google.com",status="exit_code"} 0
netcheck_http{addr="google.com",status="status_code"} 302
```

## Prometheus Config
```
  - job_name: 'netcheck'
    scrape_interval: 60s
    scrape_timeout: 30s
    metrics_path: /metric
    relabel_configs:
      - source_labels: [config]
        target_label: __param_config
        action: replace
    static_configs:
      - targets: ['127.0.0.1:9059']
        labels:
          config: 'external'

```

## TODO
- [x] http status code
- [ ] https
- [ ] netcat
- [x] arping (root permission or `$ chmod u+s $(which arping)`, `setcap`)
- [ ] ssh
- [ ] telnet
- [ ] choice of curl or wget
- [x] background job(parallel)
