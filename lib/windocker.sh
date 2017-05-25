#!/bin/bash

BASEDIR=$(dirname $0)/..

export PATH="/c/Program Files/Docker Toolbox:$PATH"
VM=${DOCKER_MACHINE_NAME-default}
DOCKER_MACHINE=docker-machine.exe

RHAP_DOCKER=${RHAP_DOCKER:-10.151.77.17}
RHAP_REG=${RHAP_REG:-rhapdocker:5000}

vboxmanage() {
  if [ ! -z "$VBOX_MSI_INSTALL_PATH" ]; then
    echo "${VBOX_MSI_INSTALL_PATH}VBoxManage.exe"
  else
    echo "${VBOX_INSTALL_PATH}VBoxManage.exe"
  fi
}

get_value() {
  local param=$1
  grep "$param" | cut -f 2 -d ':'
}

create_docker_machine() {
  local vbox=$(vboxmanage)
  local hostinfo=$("$vbox" list hostinfo)

  local cpus=$(echo "$hostinfo" | get_value 'Processor core count')
  local mem=$(echo "$hostinfo" | get_value 'Memory size' | awk '{print $1}')

  local half_mem=$(( mem  / 2 ))

  "${DOCKER_MACHINE}" create \
    --driver virtualbox \
    --virtualbox-cpu-count $cpus \
    --virtualbox-memory $half_mem \
    --virtualbox-disk-size 50000 \
    ${VM}
}

add_rhapdocker_host() {
  # this function is added into the modified version of start.sh
  "$DOCKER_MACHINE" ssh ${VM} "sudo sed -i /[[:space:]]rhapdocker/d; sudo /bin/sh -c 'echo $RHAPDOCKER rhapdocker >> /etc/hosts"
}

config_rhapdocker_cert() {
  echo "Copying rhapdocker.crt to ${VM} ..."
  "${DOCKER_MACHINE}" scp $BASEDIR/lib/rhapdocker.crt ${VM}:/tmp

  CERT_DIR=/etc/docker/$RHAP_REG
  echo "Putting rhapdocker.crt to $CERT_DIR ..."
  "${DOCKER_MACHINE}" ssh ${VM} "if [ -e $CERT_DIR ]; then sudo rm -rf $CERT_DIR; fi; sudo mkdir -p $CERT_DIR; sudo mv /tmp/rhapdocker.crt $CERT_DIR"
}

setup_docker_machine() {
  echo "Creating docker machine $VM ..."
  create_docker_machine 

  echo "Configuring rhapdocker certificate ..."
  config_rhapdocker_cert
}

"$@"
