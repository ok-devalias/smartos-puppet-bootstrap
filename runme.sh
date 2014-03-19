#  script to coordinate puppetlabs exercise 		#
########################################
#  This set of bash scripts prepares a server		#
#  with puppet, nginx, and git, then applies	#
#  a puppet manifest to set its role.						#
#  Functional and tested on:									#
#  SmartOS, Debian 6, Ubuntu 10.04 + 12.04	#
#  and CentOS 6.5												   		#
#  Expects root, but should be expanded to		#
#  use sudo when possible										#
########################################

echo "Puppet Labs - Exercise Webpage"
echo
echo
echo "Automate all the operating systems!"
echo "Puppet Bootstrap script is functional on: "
echo "-------------------------------------------------------"
echo "\t-SmartOS instances"
echo "\t-Ubuntu 10.04"
echo "\t-Ubuntu 12.04"
echo "\t-Debian 6"
echo "\t-CentOS 6"
echo "\t-Fedora 18"
echo "\t-Probably RHEL!"
echo
echo
sleep 2

echo "Starting puppet bootstrap process."
bash pupbootstrap.sh

if [ ! $? == 0 ]; then
	echo "Something went wrong in bootstrap."
	exit 1
fi

echo "Puppet bootstrap process completed."
echo
echo "Starting module install process."
bash pupmodule-inst.sh

if [ ! $? == 0 ]; then
	echo "Something went wrong in the module installation process."
	exit 1
fi

echo "Module install process completed."
echo
echo "Applying puppet manifest."
bash pupapply.sh

if [ ! $? == 0 ]; then
	echo "Something went wrong in the puppet apply process."
	exit 1
fi

echo "Puppet manifest applied."
echo
bash pupinfo.sh

