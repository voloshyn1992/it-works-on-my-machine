# it-works-on-my-machine


### Hosts
```
--------------------------------------------------
| service               |  host                   |
--------------------------------------------------
| app-js                | http://localhost:3000   |
--------------------------------------------------
| grafana               | http://localhost:9015   |
--------------------------------------------------
| cadvisor              | http://localhost:9090   |
--------------------------------------------------
| alertmanager          | http://localhost:9093   |
--------------------------------------------------
| prometheus            | http://localhost:9091   |
--------------------------------------------------
| loki                  | http://localhost:3100   |
--------------------------------------------------
| go-app                | http://localhost:8080   |
--------------------------------------------------
```

### Monitoring 

#### Loki 
Visit http://localhost:9015 and log in (credentials set in .env).
Go to Data Sources and Add data source → Loki.

URL: http://loki:3100

Click Save & test.

### Prometheus 

Visit http://localhost:9015 and log in (credentials set in .env).
Go to Data Sources and Add data source → Prometheus.

URL: http://prometheus:9015

Click Save & test.
