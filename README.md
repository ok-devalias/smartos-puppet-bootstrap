smartos-puppet-bootstrap
===============

Repository for various SmartOS-related scripts, smf manifests, and json documents.

Puppet Bootstrap scripts
------------
Puppet bootstrapping for SmartOS, Debian, Ubuntu, CentOS, and Fedora instances on SmartOS.  Bootstraps puppet, installs nginx, git, and vcsrepo modules, and applies a manifest to grab a basic index.html from git and serve through nginx on port 8080.  Works either standalone or as a customer-metadata user-script.

#### Control scripts
- runme.sh :		  			 Orchestrates scripts and informational output.
- pupbootstrap.sh :		 Detects OS and installs puppet.
- pupmodule-inst.sh : Prepares puppet modules.
- pupapply.sh :				 Applies site.pp manifest.
- pupinfo.sh :				 Displays nginx connection info.
- user-script.nfo :		 The userscript to bootstrap puppet on instance creation.

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
