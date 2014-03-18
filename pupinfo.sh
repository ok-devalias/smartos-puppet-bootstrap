# displays info for file locations and NGINX connection address

DEST=$(grep /etc/resolv.conf | cut -d' ' -f2)
IP=$(ip route get $DEST | awk 'NR==1 {print $NF}')

echo "NGINX accesible at http://$IP:8080"
echo "Puppet apply runs every 30 minutes with the following cron job."
echo " - $(crontab -l | grep pupapply.sh)"
echo
echo "Enjoy!"