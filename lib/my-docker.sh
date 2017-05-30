# XWin DISPLAY

BASEDIR=$(readlink -f $(dirname $0))/..

export DISPLAY=192.168.99.1:0.0

export USER=$(echo $USERNAME | tr [A-Z] [a-z])

export DEV_ENV=${DEV_ENV:-$HOME/dev-env}

export MY_DOCKER=${MY_DOCKER:-$HOME/my-docker}

export RHAPREG=rhapdocker:5000

find_cygwin_home() {
  if [ -d "$DEV_ENV/cygwin64" ]; then
    echo $DEV_ENV/cygwin64
  else
    echo /c/cygwin64
  fi
}

export CYGWIN_HOME=${CYGWIN_HOME:-$(find_cygwin_home)}

start_cygwin_x() {
  DOCKER_MACHINE_IP=$(docker-machine ip)
  CYGWIN_X_SH=$("$CYGWIN_HOME/bin/cygpath.exe" -u "$BASEDIR/bin/cygwin-x.sh")
  MSYS_NO_PATHCONV=1 "$CYGWIN_HOME\bin\bash.exe" -l "$CYGWIN_X_SH" $DOCKER_MACHINE_IP
}
