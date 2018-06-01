class accounts {

	@accounts::virtual { 'jsmith':
		uid             =>  2001,
		realname        =>  'John Smith',
		pass            =>  '<password here>',
		sshkeytype      =>  'ssh-rsa',
		sshkey          =>  '<ssh_public_key_here>',
#    		require         =>  Class['accounts::config'],
	}
	realize Accounts::Virtual['jsmith']
}
