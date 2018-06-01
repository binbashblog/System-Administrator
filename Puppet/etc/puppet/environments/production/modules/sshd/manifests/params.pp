
class sshd::params {
  case $::osfamily {
    debian: {
      $package_name = 'openssh-server'
      $service_name = 'ssh'
      $config_file = '/etc/ssh/sshd_config'
      $allowusers = hiera('sshd::sshd_allowusers')
    }
    ubuntu: {
      $package_name = 'openssh-server'
      $service_name = 'ssh'
      $config_file = '/etc/ssh/sshd_config'
      $allowusers = hiera('sshd:sshd_allowusers')
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

