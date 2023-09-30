#!/bin/sh

LOGPATH=/data/headunit.log
SWAPCOUNT=0
timestamp() {
  date +"%D %T"
}

check_swapfile() {
  USBDRV=$(ls /tmp/mnt | grep sd)
  for USB in $USBDRV; do
      USBPATH=/tmp/mnt/${USB}
      SWAPFILE="${USBPATH}"/swapfile
      if [ -e "${SWAPFILE}" ]; then
          if [ $(free |grep 'Swap:' |grep -v grep| awk -F "[[:space:]]+" '/ /{print $2}')  -lt 1 ]; then
              mount -o rw,remount ${USBPATH}
              swapon ${SWAPFILE}
              sleep 2
              if [ $(free |grep 'Swap:' |grep -v grep| awk -F "[[:space:]]+" '/ /{print $2}')  -lt 1 ]; then
                mkswap ${SWAPFILE}
                swapon ${SWAPFILE}
              fi
              echo "Swapfile initialized $(timestamp)'\n'" >> ${LOGPATH}
              free >> ${LOGPATH}
              sysctl vm.swappiness=10
              cat /proc/sys/vm/swappiness >> ${LOGPATH}
          fi
          break
      fi
  done
}

rm -f /tmp/root/usb_connect

LIST="/resources/aio/misc/usb-allow.list"
if ! [ -e $LIST ]; then
  LIST="/tmp/mnt/data_persist/dev/bin/usb-allow.list"
fi

while [ true ]; do

while IFS='' read -r line || [[ -n "$line" ]]; do
 count=`lsusb | grep $line|wc -l|awk '{print $1}'`
 if [ $count -gt 0 ]; then
  break
 fi
done < "$LIST"

if [ $count -gt 0 ]; then
  echo "USB Connected"
  if ! [ -e /tmp/root/usb_connect ]; then
    check_swapfile
    touch /tmp/root/usb_connect
  fi
 else
  echo "USB disconnect"
  if [ -e /tmp/root/usb_connect ]; then
   rm -f /tmp/root/usb_connect
  fi
fi
sleep 2

if [ $((++SWAPCOUNT)) -gt 30 ]; then
  check_swapfile
  SWAPCOUNT=0
fi

done
