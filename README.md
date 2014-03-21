smartos-configs
===============

Repository for various SmartOS-related scripts, smf manifests, and json documents.

Puppet Bootstrap scripts
------------
Puppet bootstrapping for SmartOS, Debian, Ubuntu, CentOS, Fedora is functional.  As is, pulls in nginx + git and grabs a basic test page from git.
#### Control scripts
- runme.sh :		  			 Orchestrates scripts and informational output.
- pupbootstrap.sh :		 Detects OS and installs puppet.
- pupmodule-inst.sh : Prepares puppet modules.
- pupapply.sh :				 Applies site.pp manifest.
- pupinfo.sh :				 Displays nginx connection info.

SmartOS persistent configs and SMF services
------------
Configurations for SmartOS and transient SMF services to ensure their presence at boot.
#### Files
- bash_history_link.xml :		Persistent .bash_history.
- bash_profile_link.xml :		Persistent .bash_profile.
- bashrc_link.xml	:					Persistent .bashrc.
- umount-shadow-svc-manifest.xml :	Transient service to allow puppet user to exist on Global Zone.
- umount-shadow.sh :			Script called by above service.
- .bashrc :									Allows use of unique aliases instead of UUID for vmadm.
- .bash_profile:						Fixes various Solaris terminal annoyances.