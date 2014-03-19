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
SCRIPT="pupapply.sh"
if [ ! "$(crontab -l | grep "$SCRIPT")" ]; then
	if [ -f "$SCRIPT" ]; then
		cp "$SCRIPT" "$PUPPET_ROOT/$SCRIPT"
	else
		if [ ! -f "$PUPPET_ROOT/$SCRIPT" ]; then
			echo "$SCRIPT unavailable; please move to either: "
			echo " - $PUPPET_ROOT/$SCRIPT"
			echo " - $(pwd)"
			echo
			echo "Terminating."
			exit 1
		fi
	fi	
	if [ -f "$PUPPET_ROOT/$SCRIPT" ]; then
		echo "Setting cron job to maintain state."
		CRON="*/30 * * * * $PUPPET_ROOT/$SCRIPT"
		echo "$CRON" >> "/etc/config/crontab"
		crontab "/etc/config/crontab"
		echo "Cron job set.  State maintained."
	else
		echo "Missing $SCRIPT at $PUPPET_ROOT"
	fi
else
	echo "Cron job detected.  State already maintained."
fi
