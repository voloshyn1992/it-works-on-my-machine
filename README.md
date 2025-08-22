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

Visit http://localhost:9090 and log in (credentials set in .env).
Go to Data Sources and Add data source → Prometheus.

URL: http://prometheus:9090

Click Save & test.

### Docker 

#### Backend

```aiignore
docker build -t volodymyrbjj/app-go:latest .
docker push volodymyrbjj/app-go:latest
```

#### Frontend

```aiignore
docker build -t volodymyrbjj/app-js:latest .
docker push volodymyrbjj/app-js:latest
```

### DB

```aiignore
psql -h "devops-course-db.crqyww60mezi.eu-north-1.rds.amazonaws.com" \
     -U "postgres" \
     -f db_schema.sql
```

### Charts
Step-by-step instruction

1. Create cluster
```aiignore
kind create cluster --name dev --config kind-ingress.yaml
kubectl cluster-info - checks cluster state
```
2. Apply ingress 

```aiignore
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx wait --for=condition=Available deploy/ingress-nginx-controller --timeout=180s
```

3. Add namespace

```aiignore
kubectl create namespace webapp
```

4. Create secrets

```aiignore
kubectl -n webapp create secret generic webapp-secret \
  --from-literal=DB_PASS=pass
  
kubectl -n webapp create secret docker-registry app-image-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=YOUR_DOCKERHUB_USER \
  --docker-password=YOUR_DOCKERHUB_PASSWORD
```

5. Adjust host

```aiignore
echo "127.0.0.1 app.local" | sudo tee -a /etc/hosts
```

6. Update helm dependencies and install charts

```aiignore
helm dep up
helm upgrade --install webapp . -n webapp -f values.yaml

kubectl -n webapp rollout status deploy/backend
kubectl -n webapp rollout status deploy/frontend
kubectl -n webapp get pods,svc
```

7. Check ingress readiness

```aiignore
kubectl -n ingress-nginx get pods
kubectl -n webapp get ingress webapp
```

8. Debug

```aiignore
kubectl -n webapp get pods -o wide
kubectl -n webapp get svc

kubectl -n webapp run redis-cli --rm -it --image=redis:7-alpine --restart=Never -- \
  sh -lc 'redis-cli -h redis-master -p 6379 ping'
# очікуємо: PONG

kubectl -n webapp run psql --rm -it --image=bitnami/postgresql:17 --restart=Never -- \
  sh -lc 'PGPASSWORD=postgres psql -h postgres -U postgres -d db -c "\l"'
```

9. Create DB

```aiignore

```