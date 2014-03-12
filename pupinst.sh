#!/bin/sh
# Install puppet and prerequisites
PKGVERS="ruby193-puppet-3.1.1"
# setup pkgin on global zone, if needed
echo "Checking OS type..."
if [[ "$MACHTYPE" == "*solaris*" ]]; then
	if [[ `uname -a` == "*joyent*" ]]; then
		echo "Found Joyent SmartOS"
		echo "Checking for pkgin..."
		if [[ ! which pkgin ]]; then
			echo "pkgin not installed."
			echo "Downloading pkgin bootstrap for SmartOS"
			cd /
			curl -k http://pkgsrc.joyent.com/packages/SmartOS/bootstrap/bootstrap-2013Q4-x86_64.tar.gz | gzcat | tar -xf -
			echo "Installing pkgin bootstrap for SmartOS"
			pkg_admin rebuild
			pkgin -y up
			echo "Done"
			echo
			# Prepare writable shadow file
			echo "Checking for loopback-mounted /etc/shadow..."
			if [[ `df | grep /etc/shadow`  ]]
				echo "Loopback found."
				echo "Preparing /etc/shadow"
				umount /usbkey/shadow
				cp /usbkey/shadow /etc/shadow
				echo "Done"
				echo
			else
				echo "/etc/shadow not loopback mounted."
				echo
			fi
		else
			echo "pkgin found."
			echo
		fi
		# Grab ruby puppet bundle installer
		echo "Installing $PKGVERS from repository"
		pkgin -y in $PKGVERS
		echo "Done"
		echo
		echo
		echo "Puppet install root is /opt/local"
	else
		echo "Found SunOS, but not Joyent SmartOS."
		echo "Exiting."
		exit 1
	fi
else
	echo "$MACHTYPE is not SunOS."
	echo "Exiting."
	exit 1
fi

