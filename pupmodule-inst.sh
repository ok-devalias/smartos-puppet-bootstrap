#!/bin/bash
# grab puppet modules jfryman-nginx and jproyo-git
# sed some changes in for SmartOS compatibility
OSBASE=$(uname)
NGINX='jfryman-nginx'
GIT='jproyo-git'
case $OSBASE in
	SunOS*)
		PUPPET_ROOT='/opt/local/etc/puppet'
	;;
	*)
		PUPPET_ROOT='/etc/puppet'
	;;	
esac

if [ ! -d "$PUPPET_ROOT"/modules/nginx ]; then
	puppet module install $NGINX > /dev/null 2&>1
	sed '/$::kernel ?/ {N; s/\(?i-mx:linux\)/\1\|sunos\)/}' < "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
	sed '/$::osfamily ?/ {N; s/\(?i-mx:\)/\1solaris\|/}' < "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
	sed 's/\(?i-mx:[a-z|]*|oraclelinux\)/\1|smartos/' < "$PUPPET_ROOT"/modules/nginx/manifests/params.pp > "$PUPPET_ROOT"/modules/nginx/manifests/params.pp
	
fi
if [ ! -d "$PUPPET_ROOT"/modules/git ]; then
	puppet module install $GIT > /dev/null 2&>1
	GIT_FIX="$bin = $::operatingsystem ? {
    /(SmartOS|Solaris)/ => '/opt/local/bin/git'
    default             => '/usr/bin/git'
  }"
  GIT_FIX_SAFE=$(printf  '%s\n' "$GIT_FIX"  | sed 's/[\&/]/\\&/g')
  sed 's/$bin =/${GIT_FIX_SAFE}/' "$PUPPET_ROOT"/modules/git/manifests/params.pp  > "$PUPPET_ROOT"/modules/git/manifests/params.pp
fi

