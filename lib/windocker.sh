#!/bin/bash

BASEDIR=$(dirname $0)

vboxmanage() {
  if [ ! -z "$VBOX_MSI_INSTALL_PATH" ]; then
    echo "${VBOX_MSI_INSTALL_PATH}VBoxManage.exe"
  else
    echo "${VBOX_INSTALL_PATH}VBoxManage.exe"
  fi
}

get-value() {
  local param=$1
  grep "$param" | cut -f 2 -d ':'
}

create-default-machine() {
  local vbox=$(vboxmanage)
  local hostinfo=$("$vbox" list hostinfo)

  local cpus=$(echo "$hostinfo" | get-value 'Processor core count')
  local mem=$(echo "$hostinfo" | get-value 'Memory size' | awk '{print $1}')

  local half_mem=$(( mem  / 2 ))

  echo $cpus
  echo $mem
  echo $half_mem
}

export PATH="/c/Program files/Docker Toolbox:$PATH"
DOCKER_MACHINE="./docker-machine"
RHAP_DOCKER=10.151.77.17
RHAP_REG=rhapdocker:5000

source $BASEDIR/my-docker.sh

setup-docker() {
  "$DOCKER_MACHINE" ssh default "sudo sed -i /[[:space:]]rhapdocker/d; sudo /bin/sh -c 'echo $RHAPDOCKER rhapdocker >> /etc/hosts"
}

pull-bi-uc4() {
  docker pull $RHAP_REG/bi/uc4:c7
}

pull-bi-intellij() {
  docker pull $RHAP_REG/bi/intellij:jdk7
}


build-user-image() {
  local image=$1
  local tag=$2

  local docker_dir=/tmp/$USER-dockerfile

  if [ -e $docker_dir ]; then
    rm -rf $docker_dir
  fi

  mkdir -p $docker_dir
  pushd $docker_dir

  cat <<EOF > dockerfile
FROM $image

RUN useradd $USER

USER $USER
EOF
  
  docker build -t $tag .

  popd
}

build-user-uc4() {
  build-user-image $RHAP_REG/bi/uc4:c7 bwang/uc4
}

build-user-intellij() {
  build-user-image $RHAP_REG/bi/intellij:jdk7 bwang/intellij
}

init-user-intellij() {
  docker run --rm -v $MY_DOCKER/intellij:/home/$USER $USER/intellij /bin/bash -l -x /opt/profile/setup.sh
}

"$@"
