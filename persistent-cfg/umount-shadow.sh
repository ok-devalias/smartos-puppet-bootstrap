# unmount shadow, add puppet user.
umount /usbkey/shadow
cp /usbkey/shadow /etc/shadow
useradd -g puppet -s /bin/false puppet