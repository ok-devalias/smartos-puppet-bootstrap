# grab puppet modules jfryman-nginx and jproyo-git
# sed some changes in for SmartOS compatibility
NGINX='jfryman-nginx'
GIT='jproyo-git'
VCSREPO='puppetlabs-vcsrepo'
OSBASE=$(uname)
case $OSBASE in
SunOS)
	PUPPET_ROOT='/opt/local/etc/puppet'
;;
*)
	PUPPET_ROOT='/etc/puppet'
;;	
esac
echo "Checking for needed puppet modules."
if [ ! $(puppet module list | grep "$NGINX") ]; then
	echo 'Installing module: "$NGINX"'
	puppet module install "$NGINX" > /dev/null 2&>1
	echo "Done."	
else
	echo "Module $NGINX detected."	
fi

if [ "$OSBASE" EQ 'SunOS*' ]; then
	echo 'Checking "$NGINX" for SmartOS fixes.'
	if [ ! $(grep sunos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp) ]; then
		sed '/$::kernel ?/ {N; s/\(?i-mx:linux\)/\1\|sunos\)/}' "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > /tmp/tmp-params.pp
		mv /tmp/tmp-params.pp  "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
		rm -f /tmp/tmp-params.pp > /dev/null 2&>1
	fi
	if [ ! $(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/params.pp) ]; then
		sed '/$::osfamily ?/ {N; s/\(?i-mx:\)/\1solaris\|/}' "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > /tmp/tmp-params.pp
		mv /tmp/tmp-params.pp  "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
		rm -f /tmp/tmp-params.pp > /dev/null 2&>1
	fi
	if [ ! $(grep smartos "$PUPPET_ROOT"/modules/nginx/manifests/params.pp) ]; then
		sed 's/\(?i-mx:[a-z|]*|oraclelinux\)/\1|smartos/' "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > /tmp/tmp-params.pp
		mv /tmp/tmp-params.pp  "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
		rm -f /tmp/tmp-params.pp > /dev/null 2&>1
	fi
	if [ ! $(grep solaris "$PUPPET_ROOT"/modules/nginx/manifests/package.pp) ]; then
		sed '$::osfamily {N; s/\(\'redhat\'\)/\1, \'solaris\'/}' "$PUPPET_ROOT"/modules/nginx/manifests/package.pp > /tmp/tmp-package.pp
		mv /tmp/tmp-package.pp "$PUPPET_ROOT"/modules/nginx/manifests/package.pp
		rm -f /tmp/tmp-package.pp > /dev/null 2&>1
	fi
	echo "Done."		
	fi
fi

if [ ! $(puppet module list | grep "$GIT") ]; then
	echo 'Installing module: "$GIT"'
	puppet module install "$GIT" > /dev/null 2&>1
	echo "Done."	
fi

if [ "$OSBASE" EQ 'SunOS*' ]; then
	GIT_FIX="\$bin = \$::operatingsystem ? {
	/(SmartOS|Solaris)/ => '/opt/local/bin/git'
	default             => '/usr/bin/git'
  }"
	GIT_FIX_SAFE=$(printf  '%s\n' "$GIT_FIX"  | sed 's/[\&/]/\\&/g')
	if [ ! $(grep SmartOS "$PUPPET_ROOT"/modules/git/manifests/params.pp) ]; then
		sed 's/$bin =/${GIT_FIX_SAFE}/' "$PUPPET_ROOT"/modules/git/manifests/params.pp  > /tmp/tmp-params.pp
		mv /tmp/tmp-params.pp "$PUPPET_ROOT"/modules/git/manifests/params.pp
		echo "Cleaning temp files..."
		rm -f /tmp/tmp-params.pp > /dev/null 2&>1
		echo "Done."
	fi
fi

if [ ! $(puppet module list | grep "$VCSREPO") ]; then
	echo 'Installing module: "$VCSREPO"'
	puppet module install "$VCSREPO" > /dev/null 2&>1
	echo "Done."	
fi
echo 
echo "All modules installed."
echo
