#!/bin/sh

type_in() {
  for c in $(echo "$@" | sed 's/./& /g' | sed 's/*/\\*/g' )
  do
    case "$c" in
      '%') c=spc ;;
      '-') c=minus ;;
      '/') c=slash ;;
      '.') c=dot ;;
      '>') c=shift-dot ;;
      '<') c=shift-comma ;;
      '=') c=equal ;;
      '"') c=apostrophe ;;
      '\*') c=asterisk ;;
      '_') echo "sendkey shift-minus" | nc -q0 127.0.0.1 $MONITOR_PORT && continue ;;
      '~') DO_UPPERCASE=yes && continue ;;
    esac

    [ "$DO_UPPERCASE" == yes ] && DO_UPPERCASE= && c="shift-$c"

    echo "sendkey $c" | nc -q0 127.0.0.1 $MONITOR_PORT
  done
  echo "sendkey kp_enter" | nc -q0 127.0.0.1 $MONITOR_PORT
}

sh download.sh
DISK=hdd.img
MONITOR_PORT=9999


qemu-img create -f qcow2 $DISK 8G
qemu-system-x86_64 \
  -enable-kvm \
  -m 1024 \
  -cdrom *.iso \
  -hda $DISK \
  -netdev user,id=ssh_net,hostfwd=tcp:127.0.0.1:12222-:22 \
  -device e1000,netdev=ssh_net \
  -monitor tcp:127.0.0.1:$MONITOR_PORT,server,nowait > /dev/null &

sleep 20
type_in root
type_in "cat%>%answer_file"
type_in '~k~e~y~m~a~p~o~p~t~s="us%us"'
echo "sendkey ctrl-d" | nc -q0 127.0.0.1 $MONITOR_PORT
type_in setup-alpine%-f%answer_file
#type_in apk%add%openssh
#type_in sed%-i%'"s/.*~permit~root~login.*/~permit~root~login%yes/g"'%/etc/ssh/sshd_config
#sleep 1
#type_in sed%-i%'"s/.*~permit~empty~passwords.*/~permit~empty~passwords%yes/g"'%/etc/ssh/sshd_config
#sleep 1
#type_in sed%-i%'"s/.*~password~authentication.*/~password~authentication%yes/g"'%/etc/ssh/sshd_config
#type_in rc-service%sshd%start
