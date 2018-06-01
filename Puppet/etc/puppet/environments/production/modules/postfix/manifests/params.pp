
class postfix::params {
      $postfix_function = hiera('postfix::postfix_function')
      $smtp_relay = hiera('postfix::smtp_relay')
      $fallback_smtp_relay = hiera('postfix::fallback_smtp_relay')
      $mail_alias = hiera_array('postfix::mail_alias')
}
