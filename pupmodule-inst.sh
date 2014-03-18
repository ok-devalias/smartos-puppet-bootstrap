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
	puppet module install "$NGINX"
	echo "Done."	
else
	echo "Module $NGINX detected."	
fi

if [ "$OSBASE" == "SunOS" ]; then
	echo "Checking $NGINX for SmartOS fixes."
	if [ ! "$(grep sunos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		echo "Applying params.pp \$::kernel compatibility fix."
		sed -i '/$::kernel ?/ {N; s/\(?i-mx:linux\)/\1\|sunos\)/}' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	else
		echo "params.pp \$::kernel compatibility fix detected."
	fi
	if [ ! "$(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		echo "Applying params.pp \$::osfamily compatibility fix."
		sed -i '/$::osfamily ?/ {N; s/\(?i-mx:\)/\1solaris\|/}' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	else
		echo "params.pp \$::osfamily compatibility fix detected."	
	fi
	if [ ! "$(grep smartos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp)" ]; then
		echo "Applying params.pp \$::operatingsystem compatibility fix."
		sed -i 's/\(?i-mx:[a-z|]*|oraclelinux\)/\1|smartos/' "$PUPPET_ROOT/modules/nginx/manifests/params.pp"
	else
		echo "params.pp \$::operatingsystem compatibility fix detected."
	fi
	if [ ! "$(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/package.pp)" ]; then
		echo "Applying package.pp \$::osfamily compatibility fix."
		sed -i "/\$::osfamily ?/ {N; s/\('redhat'\)/\1, 'solaris'/ }" "$PUPPET_ROOT/modules/nginx/manifests/package.pp"
	else
		echo "package.pp \$::osfamily compatibility fix detected."
	fi
	echo "Done."
fi

if [ ! "$(puppet module list | grep $GIT)" ]; then
	echo "Installing module: $GIT"
	puppet module install "$GIT"
	echo "Done."
else
	echo "Module $GIT detected."	
fi

if [ "$OSBASE" == "SunOS" ]; then
	echo "Checking $GIT for SmartOS fixes."
	if [ ! "$(grep SmartOS "$PUPPET_ROOT"/modules/git/manifests/params.pp)" ]; then
		echo "Applying params.pp \$::operatingsystem compatibility fix."
		sed -i 's/$bin =/$bin = $::operatingsystem ? {\
		\(SmartOS|Solaris\) => "\/opt\/local\/bin\/git"\
		default             => "\/usr\/bin\/git"\
		}/' "$PUPPET_ROOT/modules/git/manifests/params.pp"
		echo "Done."
	else 
		echo "params.pp \$::operatingsystem compatibility fix detected."
	fi
fi

if [ ! "$(puppet module list | grep $VCSREPO)" ]; then
	echo "Installing module: $VCSREPO"
	puppet module install "$VCSREPO"
	echo "Done."
else
	echo "Module $VCSREPO detected."	
fi
echo 
echo "All modules installed."
echo
