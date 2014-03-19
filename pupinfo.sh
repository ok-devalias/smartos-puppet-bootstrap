# displays info for file locations and NGINX connection address
OSBASE=$(uname)
case $OSBASE in
SunOS)
	PUPPET_ROOT="/opt/local/etc/puppet"
;;
*)
	PUPPET_ROOT="/etc/puppet"
;;	
esac
DEST=$(grep nameserver /etc/resolv.conf -m 1| cut -d' ' -f2)
IP=$(ip route get "$DEST" | awk 'NR==1 {print $NF}')

echo "NGINX accesible at http://$IP:8080"
echo "Puppet apply runs every 30 minutes with the following cron job."
echo " - $(grep -r $PUPPET_ROOT/pupapply.sh /etc/cron.d/ | cut -d: -f2)"
echo
echo "Enjoy!"