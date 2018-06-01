class accounts::config {
 
  # Place a file in /etc/profile.d to manage the prompt
  file { '/etc/profile.d/prompt.sh':
    ensure      =>  'present',
    source      =>  'puppet:///modules/config/profiled-prompt.sh',
    mode        =>  '0644',
    owner       =>  '0',
    group       =>  '0',
  }
}
