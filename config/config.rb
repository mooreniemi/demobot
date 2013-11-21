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

#gem for grabbing whole dirs
require 'require_all'

# load all ruby files in the directory "lib" and its subdirectories
require_all 'lib'
require_all 'models'
require_all 'services'
require_all 'db'

require 'cinch'
require 'sequel'

Sequel.default_timezone=:utc