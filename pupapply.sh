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

echo "Copying manifest $MANIFEST to $MANIFEST_DIR."
$(cp "$MANIFEST" "$MANIFEST_DIR/$MANIFEST" )
echo "Applying manifest."
$(puppet apply --modulepath "$MODULE_DIR" "$MANIFEST_DIR/$MANIFEST")