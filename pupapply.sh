# apply puppet manifest site.pp
OSBASE=$(uname)
case $OSBASE in
SunOS)
	PUPPET_ROOT="/opt/local/etc/puppet"
;;
*)
	PUPPET_ROOT="/etc/puppet"
;;	
esac
MANIFEST="site.pp"
MANIFEST_DIR="$PUPPET_ROOT/manifests"
MODULE_DIR="$PUPPET_ROOT/modules"

if [ ! -f "$MANIFEST_DIR/$MANIFEST" ] || [ ! "$(diff "$MANIFEST" "$MANIFEST_DIR/$MANIFEST")" ]; then	
	echo "Copying manifest $MANIFEST to $MANIFEST_DIR."
	cp "$MANIFEST" "$MANIFEST_DIR/$MANIFEST"
fi

if [ -d "$MODULE_DIR" ]; then
	echo "Applying manifest."
	puppet apply --modulepath "$MODULE_DIR" "$MANIFEST_DIR/$MANIFEST"
fi

echo "Starting Cronjob process."
bash pupcron.sh

if [ ! $? == 0 ]; then
	echo "Something went wrong in the cronjob process."
	exit 1
fi

echo "Cronjob process completed."