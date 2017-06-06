#!/bin/bash

X0_LOCK=/tmp/.X0-lock
DOCKER_MACHINE_IP=$1

start_xwin() {
  /bin/XWin :0 -multiwindow -clipboard -listen tcp &
}

grant_access() {
  if [ -n "$DOCKER_MACHINE_IP" ]; then
    /bin/xhost +"$DOCKER_MACHINE_IP"
  fi
}

if [ -f $X0_LOCK ]; then
  # XWin lock file exists, check if it is stale
  pid=$(cat $X0_LOCK)
  if ! kill -0 $pid 2>/dev/null; then
    # the process doesn't exist, start XWin
    start_xwin
  fi
else
  # The lock file doesnot exist, start XWin
  start_xwin
fi

grant_access
