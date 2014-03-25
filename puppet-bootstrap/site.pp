# /etc/puppet/manifests/site.pp
node default {
  include git

  $rootpath = $::operatingsystem ? {
    SmartOS => '/opt/local/share/www',
	default   => '/var/www/html',
  }
   
   $puppetpath = $::operatingsystem ? {
     SmartOS => '/opt/local/etc/puppet',
	 default   => '/etc/puppet',
   }
   
   class { 'nginx':
    manage_repo => false,
  }
      
  nginx::resource::vhost { 'puppetlabs_exercise':
    ensure    		=> present,
    www_root  => $rootpath,
    listen_port => '8080',	
  }
  
  vcsrepo { $rootpath:
    ensure		=> present,
	provider	=> git,
    source    	=> 'https://github.com/puppetlabs/exercise-webpage.git',
  }
  
   cron::hourly { 'pupapply.sh':
		minute      		=> '11',
		user        			=> 'root',
		command    	=> "$puppetpath/pupapply.sh",
	}
}
