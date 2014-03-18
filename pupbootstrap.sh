#!/bin/bash
# Bootstrap puppet 
OS="unknown"
# Check OS
echo "Checking OS type..."
OSBASE=$(uname)
case $OSBASE in
SunOS)
	echo "Found $OSBASE"
	echo "Checking $OSBASE version..."
	OSVER=$(uname -v)
	case $OSVER in
	joyent*)
		echo "Found SmartOS version $OSVER"
		if [ ! "$(uname -o)" ]; then
			echo "SmartOS global zone detected."
			OS="smartosgz"
		else
			echo "SmartOS instance detected."
			OS="smartosin"
		fi
		PKGVERS=$(pkgin av | grep puppet | cut -f1 -d" ")
		;;
	*)
		echo "Non-Joyent SunOS detected."
		echo "Not yet supported."
		echo "Exiting"
		echo 
		exit 1
	;;
	esac
;;	
Linux)
	echo "Found $OSBASE"
	echo "Checking $OSBASE version..."
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        OSVER=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
	elif [ -f /etc/system-release ]; then
		OSVER=$(cat /etc/system-release | cut -d' ' -f1)
    else
        OSVER=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | grep -v "system-release" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | cut -d$'\n' -f1)
    fi
	OS=$(echo "$OSVER" | tr "[:upper:]" "[:lower:]")
	echo "Found $OS"
;;
*)
	echo "Unknown OS Type:"
	echo "$OSBASE"
	echo $(uname -o)
	echo "$MACHTYPE"
	echo
	echo "Exiting."
	echo	
	exit 1
;;
esac
# prepare and install puppet
case $OS in
smartosgz)
	echo "Checking for pkgin..."
	if [ ! "$(which pkgin)" ]; then
		echo "pkgin not installed."
		echo "Downloading pkgin bootstrap for SmartOS"
		cd /
		curl -k http://pkgsrc.joyent.com/packages/SmartOS/bootstrap/bootstrap-2013Q4-x86_64.tar.gz | gzcat | tar -xf -
		echo "Installing pkgin bootstrap for SmartOS"
		pkg_admin rebuild > /dev/null 2>&1
		pkgin -y up > /dev/null 2>&1
		echo "Done"
		echo
	else
		echo "pkgin found."
		echo
	fi
	# Grab ruby puppet bundle installer
	echo "Checking for Puppet..."
	if [[ ! "$(pkgin ls | grep puppet)" ]]; then
		echo "Installing $PKGVERS from repository"
		pkgin -y in "$PKGVERS" > /dev/null 2>&1
		echo "Done"
		echo
		# make sure module and manifest directories exist
		mkdir /opt/local/etc/puppet/manifests > /dev/null 2>&1
		mkdir /opt/local/etc/puppet/modules > /dev/null 2>&1
		echo
		echo "Puppet install root is /opt/local"
		echo
	else
		echo "Puppet found."
		echo "Nothing to do."
		echo
		exit 0
	fi
;;
smartosin)
# Grab ruby puppet bundle installer
	echo "Checking for Puppet..."
	if [[ ! "$(pkgin ls | grep puppet)" ]]; then
		echo "Installing $PKGVERS from repository"
		pkgin -y in "$PKGVERS" > /dev/null 2>&1
		echo "Done"
		echo
		# make sure some directories exist
		mkdir /opt/local/etc/puppet/manifests > /dev/null 2>&1
		mkdir /opt/local/etc/puppet/modules > /dev/null 2>&1
		mkdir /opt/local/share/www > /dev/null 2>&1
		echo
		echo "Puppet install root is /opt/local"
		echo
	else
		echo "Puppet found."
		echo "Nothing to do."
		echo
		exit 0
	fi
;;
centos|redhat)
	# check for puppet
	echo "Checking for Puppet..."
	if [ ! "$(which puppet)" ]; then
		# set repo
		if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
			OSREL=$(lsb_release -r | cut -d: -f2 | sed s/'^\t'//)
		else
			OSREL=$(cut -d' ' -f3 < /etc/"$OS"-release)
		fi
		MAJVER=$(echo "$OSREL" | cut -d. -f1)
		MINVER=$(echo "$OSREL" | cut -d. -f2)
		REPOURL="https://yum.puppetlabs.com/el/$MAJVER/products/$HOSTTYPE/puppetlabs-release-$MAJVER-10.noarch.rpm"
		if [ ! "$(yum repolist | grep puppetlabs -m 1)" ]; then
			echo "Adding PuppetLabs repo: $REPOURL"
			rpm -ivh "$REPOURL"  > rpm.log 2>&1
		fi
		# install puppet prereqs and puppet
		echo "Installing puppet and dependencies"
		yum install -y puppet  > yuminst.log 2>&1
		echo "Done."
		mkdir /var/www/html > /dev/null 2>&1
		echo "Puppet Installed."
	else
		echo "Puppet found."
		echo "Nothing to do."
		echo
		exit 0
	fi
;;
debian|ubuntu)
	# check puppet 
	echo "Checking for Puppet..."
	if [ ! "$(which puppet)" ]; then
		echo "Puppet not found."		
		# set repo
		# lsb_release should be available on even minimal Debian 6 and Ubuntu 10.04/12.04 installations
		OSREL=$(lsb_release -c | cut -d: -f2 | sed s/'^\t'//)
		PKG="puppetlabs-release-$OSREL.deb"
		REPOURL="https://apt.puppetlabs.com/$PKG"
		if [ ! "$(dpkg-query -l 'puppet*' | grep '^i')" ]; then
			echo "Adding PuppetLabs repo: $REPOURL"			
			if [ -f /tmp/"$PKG" ]; then
				rm -f /tmp/"$PKG"  > /dev/null 2>&1
			fi
			curl -o /tmp/"$PKG" "$REPOURL" > /dev/null 2>&1
			dpkg -i /tmp/"$PKG"  > /dev/null 2>&1
			echo "Done."
			echo "Preparing install..."
			apt-get -qq update  > /dev/null 2>&1
		fi
		echo "Done."
		echo "Installing puppet and dependencies..."
		apt-get -qy install puppet >> aptget.inst.log 2>&1
		rm -f /tmp/"$PKG" > /dev/null 2>&1
		echo "Done."
		mkdir /var/www/html > /dev/null 2>&1
		echo "Puppet Installed."
	else
		echo "Puppet found."
		echo "Nothing to do."
		echo
		exit 0
	fi
;;
*)
	echo "Unknown OS: $OS"
	exit 1
;;
esac