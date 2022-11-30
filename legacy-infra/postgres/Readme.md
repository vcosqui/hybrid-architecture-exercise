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
To get the password for "postgres" run:

```shell
    export POSTGRES_ADMIN_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
```
To get the password for "merchant" run:

```shell
    export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.password}" | base64 -d)
```
To connect to your database run the following command:

```shell
    kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.1.0-debian-11-r0 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host postgresql -U merchant -d merchant -p 5432
```

    > NOTE: If you access the container using bash, make sure that you execute "/opt/bitnami/scripts/postgresql/entrypoint.sh /bin/bash" in order to avoid the error "psql: local user with ID 1001} does not exist"

To connect to your database from outside the cluster execute the following commands:

```shell
kubectl port-forward --namespace default svc/postgresql 5432:5432 & 
PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U merchant -d merchant -p 5432
```
