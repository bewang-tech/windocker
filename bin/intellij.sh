# The common function to start Intellij Idea or developer shell environment
# all docker options should put at the beginnings. 
# The first word without `-` and its followings are treated as a command
# and its arguments.
run_intellij() {
  local opts=""

  for o in "$@"; do
    case $o in
      -*) 
	opts="$opts $o"
	shift
	;;
      *) break;;
    esac
  done
  local cmd="$@"

  docker run $opts
    --rm \
    -e DISPLAY=$DISPLAY \
    -v /mnt/sda1/$USER/intellij:/home/$USER \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --dns-search sea2.rhapsody.com \
    --dns-search sea1.rhapsody.com \
    --dns-search corp.rhapsody.com \
    --dns-search internal.rhapsody.com \
    --dns-search rhapsody.com \
    $USER/intellij $cmd 
}
