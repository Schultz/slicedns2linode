# Slicehost DNS to Linode Script


# Installation

# Grab script from Github open it and replace your SLICEHOST_API_KEY, LINODE_API_KEY and EMAIL_ADDRESS

# Usage

    ./slicedns2linode.rb domain1.com. [domain2.com.]

There is only 1 required arguments for the script. The name of your domain with the trailing period [.]. You can add additional domains to be transferred in a single run just seperate them with a space

# Requirements

You need to make sure you have activeresource installed
gem install activeresource

You need to have linode ruby library intalled
gem install linode

# TODO 
Create GEM 
Create Test coverage