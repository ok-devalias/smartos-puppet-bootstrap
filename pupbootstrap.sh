#!/bin/bash
# Bootstrap puppet 
PKGVERS=$(pkgin av | grep puppet | cut -f1 -d" ")
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
		if [ ! `uname -o` ]; then
			echo "SmartOS global zone detected."
			OS="smartosgz"
		else
			echo "SmartOS instance detected."
			OS="smartosin"
		fi
		;;
	*)
		echo "Non-Joyent SunOS detected."
		echo "Not yet supported."
		echo "Exiting"
		echo 		
		exit 1
		;;	
	;;
Linux)
	echo "Found $OSBASE"
	echo "Checking $OSBASE version..."	
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        OSVER=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    else
        OSVER=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
	OS=$(echo $OSVER | tr "[:upper:]" "[:lower:]")
	echo "Found $OS"
	;;
*)
	echo "Unknown OS Type:"
	echo "$OSBASE"
	echo `uname -o`
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
		if [ ! `which pkgin` ]; then
			echo "pkgin not installed."
			echo "Downloading pkgin bootstrap for SmartOS"
			cd /
			`curl -k http://pkgsrc.joyent.com/packages/SmartOS/bootstrap/bootstrap-2013Q4-x86_64.tar.gz | gzcat | tar -xf -`
			echo "Installing pkgin bootstrap for SmartOS"
			`pkg_admin rebuild`
			`pkgin -y up`
			echo "Done"
			echo			
		else
			echo "pkgin found."
			echo
		fi
		# Grab ruby puppet bundle installer
		echo "Checking for Puppet..."
		if [[ ! `pkgin ls | grep puppet`  ]]; then
			echo "Installing $PKGVERS from repository"
			`pkgin -y in $PKGVERS`
			echo "Done"
			echo
			echo
			echo "Puppet install root is /opt/local"
			echo
		else
			echo "Puppet found."
			echo "Nothing to do."
			echo			
		fi
;;
smartosin)
# Grab ruby puppet bundle installer
	echo "Checking for Puppet..."
		if [[ ! `pkgin ls | grep puppet`  ]]; then
			echo "Installing $PKGVERS from repository"
			`pkgin -y in $PKGVERS`
			echo "Done"
			echo
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
# check puppet repo
	OSREL=$(lsb_release -r | cut -d: -f2 | sed s/'^\t'//)
	MAJVER=$(cut -d. -f1 $OSREL)
	MINVER=$(cut -d. -f2 $OSREL)
	REPOURL="https://yum.puppetlabs.com/el/$MAJVER/products/$HOSTTYPE/puppetlabs-release-$MAJVER-10.noarch.rpm"
	echo "Adding PuppetLabs repo: $REPOURL"
	`rpm -ivh $REPOURL`
# install puppet prereqs and puppet
	echo "Installing puppet and dependencies"
	`yum install -y puppet`
;;
debian|ubuntu)
# check puppet repo
	echo "Not yet supported."
# install puppet prereqs and puppet
;;
*)
	echo "Unknown OS: $OS"
;;
esac
