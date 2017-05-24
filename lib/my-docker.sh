# X-win DISPLAY
HOST_IP=$(perl -e 'use Net::Domain qw(hostname); use Socket; print inet_ntoa(scalar gethostbyname(hostname()));'); 
export DISPLAY=$HOST_IP:0.0
export USER=$(echo $USERNAME | tr [A-Z] [a-z])
export MY_DOCKER=$HOME/my-docker

$BASEDIR/cygwin-x.bat
