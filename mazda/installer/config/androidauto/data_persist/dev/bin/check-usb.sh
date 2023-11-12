#!/bin/sh

LOGPATH=/data/headunit.log
timestamp() {
  date +"%D %T"
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
    touch /tmp/root/usb_connect
  fi
 else
  echo "USB disconnect"
  if [ -e /tmp/root/usb_connect ]; then
   /jci/scripts/resetvip
   rm -f /tmp/root/usb_connect
  fi
fi
sleep 2

done
