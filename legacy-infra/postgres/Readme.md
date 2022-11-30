# Provisioning and populating a Postgres database in kubernetes 

These are the instructions to deploy the `merchant` postgres database.

For more details see https://adamtheautomator.com/postgres-to-kubernetes/

## Add postgres helm repository
```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm repo list
```

## Deploy persistent volume
```shell
kubectl apply -f pv.yaml
kubectl get pv
```

## Deploy persistent volume claim
```shell
kubectl apply -f pvc.yaml
kubectl get pvc
```

## Deploy postgres with helm
```shell
helm install postgresql -f values.yaml bitnami/postgresql
```

## Some useful commands

PostgreSQL can be accessed via port 5432 on the following DNS names from within your cluster:

```shell
    postgresql.default.svc.cluster.local - Read/Write connection
```

To connect to your database from outside the cluster execute the following commands:

```shell
 kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.1.0-debian-11-r0 --env="PGPASSWORD=m3rch4nt" \
      --command -- psql --host postgresql -U merchant -d merchant -p 5432
```
## Uninstall
```shell
helm uninstall postgresql
```