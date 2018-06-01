
class ntp::service {
        service { 'ntp':
                name    => $ntp::params::service_name,
                ensure  => running,
                enable  => true,
                subscribe       => File["$ntp::params::config_file"]
        }
}
