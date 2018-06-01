
class ntp::params {
  case $::osfamily {
    debian: {
      $package_name = 'ntp'
      $service_name = 'ntp'
      $config_file = '/etc/ntp.conf'
      $servers = hiera('ntp::ntp_servers')
      $restrict = hiera('ntp::ntp_restrict')
    }
    redhat: {
      $package_name = 'ntpd'
      $service_name = 'ntpd'
      $config_file = '/etc/ntp.conf'
      $servers = hiera('ntp::ntp_servers')
      $restrict = hiera('ntp::ntp_restrict')
    }
    default: {
      case $::operatingsystem {
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}

