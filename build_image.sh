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
    sleep 0.1
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

sleep 30
type_in root
type_in "cat%>%answer_file"
type_in '~k~e~y~m~a~p~o~p~t~s="us%us"'
type_in '~h~o~s~t~n~a~m~e~o~p~t~s="-n%playground"'
type_in '~i~n~t~e~r~f~a~c~e~s~o~p~t~s="auto%lo'
type_in 'iface%lo%inet%loopback'
type_in 'auto%eth0'
type_in 'iface%eth0%inet%dhcp"'
type_in '~d~n~s~o~p~t~s="-d%google.com%8.8.8.8"'
type_in '~t~i~m~e~z~o~n~e~o~p~t~s="-z%~u~t~c"'
type_in '~p~r~o~x~y~o~p~t~s="none"'
type_in '~a~p~k~r~e~p~o~s~o~p~t~s="-f"'
type_in '~s~s~h~d~o~p~t~s="-c%openssh"'
type_in '~n~t~p~o~p~t~s="-c%chrony"'
type_in '~d~i~s~k~o~p~t~s="-m%sys%/dev/sda"'
echo "sendkey ctrl-d" | nc -q0 127.0.0.1 $MONITOR_PORT
type_in setup-alpine%-f%answer_file
sleep 30
type_in 1
type_in 1
type_in y
type_in poweroff
wait $(jobs -p)

qemu-system-x86_64 \
  -enable-kvm \
  -m 1024 \
  -hda $DISK \
  -netdev user,id=ssh_net,hostfwd=tcp:127.0.0.1:12222-:22 \
  -device e1000,netdev=ssh_net \
  -monitor tcp:127.0.0.1:$MONITOR_PORT,server,nowait > /dev/null &

sleep 30

type_in root
sleep 0.5
type_in 1
sleep 0.5
type_in sed%-i%'"s/.*~permit~root~login.*/~permit~root~login%yes/g"'%/etc/ssh/sshd_config
sleep 1
type_in sed%-i%'"s/.*~permit~empty~passwords.*/~permit~empty~passwords%yes/g"'%/etc/ssh/sshd_config
sleep 1
type_in sed%-i%'"s/.*~password~authentication.*/~password~authentication%yes/g"'%/etc/ssh/sshd_config
type_in rc-service%sshd%restart
sleep 20


DOCKER_INSTALL_SCRIPT='
sed -i -e 1d -e "s/#//" /etc/apk/repositories &&
apk update ;
apk add tmux;
apk add docker;
rc-update add docker default;
rc-service docker start;
sleep 5;
docker pull ubuntu;
docker pull busybox;
docker pull mcr.microsoft.com/powershell
'

SSHPASS=1 sshpass -e ssh -oStrictHostKeyChecking=no root@localhost -p 12222 "$DOCKER_INSTALL_SCRIPT"
