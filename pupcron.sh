# set cronjob for puppet apply maintenance
OSBASE=$(uname)
case $OSBASE in
SunOS)
	PUPPET_ROOT="/opt/local/etc/puppet"
;;
*)
	PUPPET_ROOT="/etc/puppet"
;;	
esac
MANIFEST_DIR="$PUPPET_ROOT/manifests"

if [ ! $(crontab -l | grep "pupapply.sh") ]; then
	cp "pupapply.sh" "$PUPPET_ROOT/pupapply.sh"
	echo "Setting cron job to maintain state."
	CRON="*/30 * * * * $PUPPET_ROOT/pupapply.sh"
	crontab < echo "$CRON"
	echo "Cron job set.  State maintained."
else
	echo "Cron job detected.  State already maintained."
fi

