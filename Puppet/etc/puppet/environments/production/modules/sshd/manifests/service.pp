
class sshd::service {
        service { 'ssh':
                name    	=> 	$sshd::params::service_name,
                ensure  	=> 	running,
                enable  	=> 	true,
		require 	=> 	Package["openssh-server"],
                subscribe       => 	File["$sshd::params::config_file"]
        }
}
