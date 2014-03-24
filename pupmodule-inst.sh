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
	export PATH="$PATH:/opt/local/bin"	
	# ugly fix for puppet 3.1.1, the available package in smartos pkgin repo.
	if [ "$(/opt/local/bin/puppet --version)" == "3.1.1" ]; then
		sed -i '' -e '/defaultfor :operatingsystem/ { s/\(:dragonfly, :netbsd\)/\1, :smartos/; } ' '/opt/local/lib/ruby/gems/1.9.3/gems/puppet-3.1.1/lib/puppet/provider/package/pkgin.rb'
	fi
;;
*)
	PUPPET_ROOT="/etc/puppet"
;;	
esac
MODULE_DIR="$PUPPET_ROOT/modules"
 
echo "Checking for needed puppet modules."
if [ ! "$(puppet module list | grep nginx)" ]; then
	echo "Installing module: $NGINX"	
	# puppet forge module jfryman-nginx does not support solaris or smartos, so github fork is used.
	if [ "$OSBASE" == "SunOS" ]; then
	    echo "Installing prerequisite modules."
		puppet module install puppetlabs-concat 2>&1		
		puppet module install puppetlabs-apt 2>&1
		echo "Installing git"
		pkgin -y in git > /dev/null 2>&1
		# git clone https://github.com/"$(sed "s/$NGINX/\//")" "$MODULE_DIR/nginx" ## use if pull request accepted
		echo "Cloning nginx module from github for SmartOS compatibility."
		if [ ! -d "$MODULE_DIR/nginx" ]; then
			mkdir "$MODULE_DIR/nginx"
		fi
		git clone https://github.com/ok-devalias/puppet-nginx.git "$MODULE_DIR/nginx"
	else
		puppet module install "$NGINX"
	fi
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
