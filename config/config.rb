$config = {
# names of you and your stupid friends go here
:bot_owners => ["ChanServ","modulus"],

# allow users to register and log in with the bot?
:enable_bot_auth => false, # for production.

# keep voting data in the db even after they expire?
:keep_votings => true,

# in seconds
:voteban_voting_duration => 300,
:sponsor_voting_duration => 600,
:condemn_voting_duration => 600,

:voteban_required_votes => lambda { |active_users, total_users|
  # pretty arbitrary as of now
  active_users < 3 ? 5 : active_users/2
},
:sponsor_required_votes => lambda { |active_users, total_users|
  return ((total_users/active_users)/4)+(active_users/2)
},
:condemn_required_votes => lambda { |active_users, total_users|
  return ((total_users/active_users)/4)+(active_users/2)
},

# in seconds
:voteban_ban_duration => 604800

} # Hash for config info.

require 'cinch'
require './auth'
require './command'
require './util' # for formatting stuff

require 'sequel'

Sequel.default_timezone=:utc

# Modules/network-specific requires
require './freenode_auth'

# Actual voting stuff
require './voting'