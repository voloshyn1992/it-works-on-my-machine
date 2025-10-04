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
kind create cluster --name dev --config charts/cluster-ingress.yaml
kubectl cluster-info --context kind-dev - checks cluster state
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
  --from-literal=DB_PASS=db_password
  
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
# Run to `/charts/webapp` folder and run
helm dep up
helm upgrade --install webapp . -n webapp -f values.yaml

kubectl -n webapp rollout status deploy/backend
kubectl -n webapp rollout status deploy/frontend
kubectl -n webapp get pods,svc
```

7. Check ingress readiness

```aiignore
kubectl -n ingress-nginx get pods
kubectl -n webapp get ingress
kubectl -n webapp describe ingress webapp-frontend
kubectl -n webapp describe ingress webapp-backend-rewrite
```

8. Debug

```aiignore
kubectl -n webapp get pods -o wide
kubectl -n webapp get svc

kubectl -n webapp run redis-cli --rm -it --image=redis:7-alpine --restart=Never -- \
  sh -lc 'redis-cli -h redis-master -p 6379 ping'
# expect: PONG

kubectl -n webapp run psql --rm -it --image=bitnami/postgresql:17 --restart=Never -- \
  sh -lc 'PGPASSWORD=postgres psql -h postgres -U postgres -d db -c "\l"'
```

9. Create DB

```aiignore
kubectl -n webapp run psql --rm -it --image=postgres:17 --restart=Never -- \
  bash -lc '
export PGPASSWORD=postgres
psql -h postgres -U postgres -d postgres <<'"'"'SQL'"'"'
SELECT '\''CREATE DATABASE db'\'' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '\''db'\'') \gexec
\c db
CREATE TABLE IF NOT EXISTS public.videos (
  id VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL
);
SQL
'
```

10. Install Argocd

```aiignore
brew install argocd
argocd version --client

kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server

# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
  
# Port-forward, login, and change password
kubectl -n argocd port-forward svc/argocd-server 8081:443 >/dev/null 2>&1 &

argocd login localhost:8081 --username admin --password <the-password> --insecure
argocd account update-password

# Remove the initial secret per docs
kubectl -n argocd delete secret argocd-initial-admin-secret

# Kill port-forward process
pkill -f "kubectl.*port-forward.*argocd-server" || true

# Let argo cd and updater write to the repo
argocd repo add https://github.com/voloshyn1992/it-works-on-my-machine.git \
  --username <your_github_user> \
  --password <your_github_pat> \
  --name my-repo

# Install argocd image updated
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
  
# Create secret for argocd namespace for dockerhub
kubectl -n argocd create secret docker-registry dockerhub-creds \
  --docker-server=https://registry-1.docker.io \
  --docker-username="$DOCKERHUB_USER" \
  --docker-password="$DOCKERHUB_TOKEN"
  
#Run from it-works-on-my-machine and apply argocd charts
kubectl apply -f gitops/app-webapp.yaml
kubectl -n argocd port-forward svc/argocd-server 8081:443
argocd app wait webapp

# Check status
kubectl -n argocd get pods  

# If some pods crashed can be the problem with free space (clean volumes, unnecessary images etc.)
```

11. First sync via Argo 

```aiignore
argocd app get webapp
kubectl -n webapp get pods,svc,ingress
```

12. Browse to the app

```aiignore
# backend routes are under http://app.local/api/...
http://app.local/

# Argo CD 
kubectl -n argocd port-forward svc/argocd-server 8081:443
http://app.local:8081/
```

14. Run actions locally

```aiignore
# Install
brew install act

# Create a .secrets file
DOCKERHUB_USERNAME=your_dockerhub_user
DOCKERHUB_TOKEN=your_dockerhub_token

# Run the workflow job locally from it-works-on-my-machine
# backend
act workflow_dispatch \
  -W .github/workflows/deploy-build-push-backend.yaml \
  --secret-file .secrets \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest

#frontend
act workflow_dispatch \
  -W .github/workflows/deploy-build-push-frontend.yaml \
  --secret-file .secrets \
  -P ubuntu-latest=catthehacker/ubuntu:act-latest
```

15. Verify it works

```aiignore
kubectl -n argocd logs -f deploy/argocd-image-updater | egrep 'webapp|updated|app-go|app-js'
kubectl -n webapp rollout status deploy/backend
kubectl -n webapp rollout status deploy/frontend
kubectl -n webapp get deploy backend  -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
kubectl -n webapp get deploy frontend -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

