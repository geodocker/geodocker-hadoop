#! /usr/bin/env bash
set -eo pipefail
source hdfs-lib.sh

# No matter what, this runs
if [[ ! -v ${HADOOP_MASTER_ADDRESS} ]]; then
  sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
fi

# The first argument determines whether this container runs as data, namenode or secondary namenode
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'name', 'sname', 'data'"
  exit 1
else
  if [ $1 = "name" ]; then
    if  [[ ! -f /data/hdfs/name/current/VERSION ]]; then
      echo "Formatting namenode root fs in /data/hdfs/name..."
      hdfs namenode -format
      echo
    fi
    exec hdfs namenode
  elif [ $1 = "sname" ]; then
    wait_until_port_open ${HADOOP_MASTER_ADDRESS} 8020

    exec hdfs secondarynamenode
  elif [ $1 = "data" ]; then
    wait_until_port_open ${HADOOP_MASTER_ADDRESS} 8020
    exec hdfs datanode
  else
    exec "$@"
  fi
fi
