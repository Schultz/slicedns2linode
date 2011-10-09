# Slicehost DNS to Linode Script


# Installation

Grab script from Github open it and replace your SLICEHOST\_API\_KEY, LINODE\_API\_KEY and EMAIL_ADDRESS

And then run

  $ bundle install

# Usage

    bundle exec ./slicedns2linode.rb domain1.com. [domain2.com.]

There is only 1 required argument for the script. The name of your domain with the trailing period [.]. You can add additional domains to be transferred in a single run just separate them with a space

# Requirements
You need to have a working ruby and rubygems installation

	# Ubuntu Install
	$ [sudo] aptitude install ruby rubygems
	# Ubuntu Server might also need the ruby OpenSSL libraries installed. 
	$ [sudo] aptitude install libopenssl-ruby
	# Fedora Install
	$ [sudo] yum install ruby rubygems
	
You need to make sure you have bundler installed

    $ [sudo] gem install bundler

# TODO 
Create GEM  
Create Test coverage