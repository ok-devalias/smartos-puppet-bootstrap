# /etc/puppet/manifests/site.pp
node default {
  include nginx
  include git  
  include cron

   $rootpath = $::operatingsystem ? {
     SmartOS => '/opt/local/share/www',
	 default   => '/var/www/html',
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
  
  cron::hourly {
	  'pupapply.sh':
		minute      		=> '11',
		user        			=> 'root',
		command    	=> "/root/pupapply.sh",
	}
}
