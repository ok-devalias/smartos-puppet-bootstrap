# grab puppet modules jfryman-nginx, jproyo-git, and puppetlabs-vcsrepo
# sed some changes in for SmartOS compatibility

NGINX="jfryman-nginx"
GIT="puppetlabs-git"
CRON="torrancew-cron"
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
MODULE_DIR="$PUPPET_ROOT/modules"

# ugly fix for puppet 3.1.1, the available package in smartos pkgin repo.
if [ "$(puppet --version)" == "3.1.1" ]; then
	if [ "$OSBASE" == "SunOS" ]; then
		sed -i '/defaultfor :operatingsystem/ { s/\(:dragonfly, :netbsd\)/\1, :smartos/; } ' '/opt/local/lib/ruby/gems/1.9.3/gems/puppet-3.1.1/lib/puppet/provider/package/pkgin.rb'
	fi
fi
 
echo "Checking for needed puppet modules."
if [ ! "$(puppet module list | grep $NGINX)" ]; then
	echo "Installing module: $NGINX"
	puppet module install "$NGINX"
	echo "Done."
else
	echo "Module $NGINX detected."
fi

if [ ! "$(puppet module list | grep $GIT)" ]; then
	echo "Installing module: $GIT"
	puppet module install "$GIT"
	echo "Done."
else
	echo "Module $GIT detected."	
fi

if [ ! "$(puppet module list | grep $CRON)" ]; then
	echo "Installing module: $CRON"
	puppet module install "$CRON"
	echo "Done."
else
	echo "Module $CRON detected."	
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
