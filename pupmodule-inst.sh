# grab puppet modules jfryman-nginx, jproyo-git, and puppetlabs-vcsrepo
# sed some changes in for SmartOS compatibility

NGINX="jfryman-nginx"
GIT="jproyo-git"
VCSREPO="puppetlabs-vcsrepo"
OSBASE=$(uname)
case $OSBASE in
SunOS)
	PUPPET_ROOT="/opt/local/etc/puppet"
;;
*)
	PUPPET_ROOT="/etc/puppet"
;;	
esac
echo "Checking for needed puppet modules."
if [ ! "$(puppet module list | grep $NGINX)" ]; then
	echo "Installing module: $NGINX"
	puppet module install "$NGINX" > /dev/null 2&>1
	echo "Done."	
else
	echo "Module $NGINX detected."	
fi

if [ "$OSBASE" == "SunOS" ]; then
	echo "Checking $NGINX for SmartOS fixes."
	if [ ! "$(grep sunos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		sed -i '/$::kernel ?/ {N; s/\(?i-mx:linux\)/\1\|sunos\)/}' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	fi
	if [ ! "$(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		sed -i '/$::osfamily ?/ {N; s/\(?i-mx:\)/\1solaris\|/}' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	fi
	if [ ! "$(grep smartos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		sed -i 's/\(?i-mx:[a-z|]*|oraclelinux\)/\1|smartos/' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	fi
	if [ ! "$(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/package.pp)" ]; then
		sed -i '$::osfamily ?/ {N; s/\('\''redhat'\''\)/\1, '\''solaris'\''/}' "$PUPPET_ROOT/modules/nginx/manifests/package.pp"		
	fi
	echo "Done."
fi

if [ ! "$(puppet module list | grep "$GIT")" ]; then
	echo "Installing module: $GIT"
	puppet module install "$GIT" > /dev/null 2&>1
	echo "Done."
fi

if [ "$OSBASE" == "SunOS" ]; then
	if [ ! "$(grep SmartOS "$PUPPET_ROOT"/modules/git/manifests/params.pp)" ]; then
		GIT_FIX="\$bin = \$::operatingsystem ? {\n/(SmartOS|Solaris)/ => '/opt/local/bin/git'\ndefault             => '/usr/bin/git'\n}"
		sed -i "s/\$bin =/{$GIT_FIX}/" "$PUPPET_ROOT/modules/git/manifests/params.pp"		
		echo "Done."
	fi
fi

if [ ! "$(puppet module list | grep "$VCSREPO")" ]; then
	echo "Installing module: $VCSREPO"
	puppet module install "$VCSREPO" > /dev/null 2&>1
	echo "Done."	
fi
echo 
echo "All modules installed."
echo
