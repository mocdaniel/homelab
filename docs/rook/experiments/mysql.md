# MySQL

The aim of this scenario is to see whether a MySQL instance deployed via
the [Bitnami Helm chart](https://github.com/bitnami/charts/tree/main/bitnami/mysql)
can

1. use a PVC served by Rook
2. can be moved from one node to another without data loss

## Deploying MySQL

The following command deploys a single pod `mysql-experiment-0` to the namespace
`experiments`. It will claim a **RWO** volume of `8GB` in size.

The `primary.persistentVolumeClaimRetentionPolicy...` values will
ensure that the PVC and PV will get cleaned up upon removal of the database.

```console
helm repo add bitnami https://charts.binami.com/bitnami
helm repo update
helm install -n experiments --create-namespace \
  mysql-experiment bitnami/mysql \
  --set primary.persistentVolumeClaimRetentionPolicy.enabled=true \
  --set primary.persistentVolumeClaimRetentionPolicy.whenDeleted=Delete
```

## Tests

Check if the PVC got created and we can shutdown the pod without data loss:

```console
kubectl get pvc -n experiments

NAME                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
data-mysql-experiment-0   Bound    pvc-41974e40-0064-4c3a-916a-afb312470f82   8Gi        RWO            ceph-block     4m50s
```

Create and show a new database inside the new database server:

```console
export MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace experiments \
  mysql-experiment -o jsonpath="{.data.mysql-root-password}" | base64 -d)

kubectl run mysql-experiment-client \
  --rm --tty -i --restart='Never' \
  --image docker.io/bitnami/mysql:8.0.36-debian-12-r8 \
  --namespace experiments \
  --env MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD 
  --command -- bash

$ mysql -h mysql-experiment.experiments.svc.cluster.local -uroot -p"$MYSQL_ROOT_PASSWORD"
mysql> create database helloworld;
Query OK, 1 row affected (0.09 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| helloworld         |
| information_schema |
| my_database        |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
6 rows in set (0.02 sec)
```

Now, delete the `mysql-experiment-0` pod from another terminal:

```console
kubectl delete pod -n experiments mysql-experiment-0
```

Wait for the pod to come up again and display all databases again.
`helloworld` should still exist.

Next, `cordon` the node the pod is running on, and delete it again - this will
force it to get rescheduled on a different node:

```console
export NODE=$(kubectl get pod -n experiments mysql-experiment-0 -o jsonpath={.spec.nodeName})
kubectl cordon $NODE
```

Then, delete the `mysql-experment-0` pod once more, same as above.

Wait for the pod to come up again **on a different node** and display all
databases once more. `helloworld` should still exist.

## Cleanup

Uninstall the `mysql-experiment` release:

```console
helm uninstall -n experiments mysql-experiment
```

The dangling PVC should get cleaned up automatically.
