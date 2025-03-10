#!/usr/bin/env bash

set -e

DB_HOST="127.0.0.1"
DB_PORT="4002"
TABLE_NAME="greptimedb_cluster_test"

CreateTableSQL="CREATE TABLE %s (
                        ts TIMESTAMP DEFAULT current_timestamp(),
                        n INT,
    					          row_id INT,
                        TIME INDEX (ts),
                        PRIMARY KEY(n)
               )
               PARTITION ON COLUMNS (n) (
                   n < 5,
                   n >= 5 AND n < 9,
                   n >= 9
					     )"

InsertDataSQL="INSERT INTO %s(n, row_id) VALUES (%d, %d)"

SelectDataSQL="SELECT * FROM %s"

DropTableSQL="DROP TABLE %s"

TestRowIDNum=1

function create_table() {
  local table_name=$1
  local sql=$(printf "$CreateTableSQL" "$table_name")
  mysql -h "$DB_HOST" -P "$DB_PORT" -e "$sql"
}

function insert_data() {
  local table_name=$1
  local sql=$(printf "$InsertDataSQL" "$table_name" "$TestRowIDNum" "$TestRowIDNum")
  mysql -h "$DB_HOST" -P "$DB_PORT" -e "$sql"
}

function select_data() {
  local table_name=$1
  local sql=$(printf "$SelectDataSQL" "$table_name")
  mysql -h "$DB_HOST" -P "$DB_PORT" -e "$sql"
}

function drop_table() {
  local table_name=$1
  local sql=$(printf "$DropTableSQL" "$table_name")
  mysql -h "$DB_HOST" -P "$DB_PORT" -e "$sql"
}

function deploy_greptimedb_cluster() {
  # Handle greptimedb-cluster dependencies.
  helm repo add grafana https://grafana.github.io/helm-charts --force-update
  helm repo add jaeger-all-in-one https://raw.githubusercontent.com/hansehe/jaeger-all-in-one/master/helm/charts --force-update
  helm dependency build charts/greptimedb-cluster

  # Deploy greptimedb cluster.
  helm upgrade --install mycluster charts/greptimedb-cluster -n default

  timeout=300
  sleep_interval=5
  elapsed_time=0

  # Wait for greptimedb cluster to be ready
  while true; do
    PHASE=$(kubectl -n default get gtc mycluster -o jsonpath='{.status.clusterPhase}')
    if [ "$PHASE" == "Running" ]; then
      echo "Cluster is ready"
      break
    elif [ $elapsed_time -ge $timeout ]; then
      echo "Timed out waiting for cluster to be ready"
      exit 1
    else
      echo "Cluster is not ready yet: Current phase: $PHASE"
      sleep $sleep_interval # wait for 5 seconds before check again
    fi
    elapsed_time=$((elapsed_time + sleep_interval))
  done
}

function deploy_greptimedb_operator() {
  helm upgrade --install greptimedb-operator charts/greptimedb-operator -n default

  # Wait for greptimedb operator to be ready
  kubectl rollout status --timeout=60s deployment/greptimedb-operator -n default
}

function deploy_etcd() {
  helm upgrade --install etcd \
    oci://registry-1.docker.io/bitnamicharts/etcd \
    --set replicaCount=1 \
    --set auth.rbac.create=false \
    --set auth.rbac.token.enabled=false \
    --create-namespace \
    -n etcd-cluster

  # Wait for etcd to be ready
  kubectl rollout status --timeout=120s statefulset/etcd -n etcd-cluster
}

function mysql_test_greptimedb_cluster() {
  kubectl port-forward -n default svc/mycluster-frontend \
    4000:4000 \
    4001:4001 \
    4002:4002 \
    4003:4003 > /tmp/connections.out &

  sleep 5

  create_table "$TABLE_NAME"
  insert_data "$TABLE_NAME"
  select_data "$TABLE_NAME"
  drop_table "$TABLE_NAME"
}

function cleanup() {
  echo "Cleaning up..."
  pkill -f "kubectl port-forward"
}

function main() {
  # Deploy the bitnami etcd helm chart
  deploy_etcd

  # Deploy the greptimedb-operator helm chart
  deploy_greptimedb_operator

  # Deploy the greptimedb-cluster helm chart
  deploy_greptimedb_cluster

  # Add mysql test with greptimedb cluster
  mysql_test_greptimedb_cluster

  # clean resource
  cleanup
}

main
