pull_bi_uc4() {
  docker pull $RHAP_REG/bi/uc4
}

pull_bi_intellij() {
  docker pull $RHAP_REG/bi/intellij
}

build_user_image() {
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

RUN useradd $USER \
    echo "$USER ALL=(ALL) NOPASSWORD: ALL" >> /etc/sudoers

USER $USER
EOF
  
  docker build -t $tag .

  popd
}

build_user_uc4() {
  build_user_image $RHAP_REG/bi/uc4 bwang/uc4
}

build_user_intellij() {
  build_user_image $RHAP_REG/bi/intelij bwang/intellij
}

init_user_intellij() {
  docker run --rm \
    -v $MY_DOCKER/intellij:/home/$USER \
    $USER/intellij \
    /bin/bash -l -x /opt/profile/setup.sh
} 

setup_developer_env() {
  echo "Pulling bi/uc4 ..."
  pull_uc4_image

  echo "Pulling bi/intellij ..."
  pull_intellij_image

  echo "Building $USER/uc4 ..."
  build_user_uc4

  echo "Building $USER/intellij ..."
  build_user_intellij

  echo "Initializing $USER/intellij ..."
  init_user_intellij
}

"$@"
