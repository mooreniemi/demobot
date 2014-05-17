require 'pry' # for debugging

require 'cinch'
require 'cinch/extensions/authentication'
require 'sequel'

# classes included
require_relative 'constants'
require_relative 'db'
require_relative 'user'
require_relative 'ballot'
require_relative 'ops'

# plugins
require_relative 'hello'
require_relative 'admin'
require_relative 'cast_ballot'

# bot initialized
demobot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "demobot"
    c.channels = ["#demobot"]
    c.plugins.plugins = [HelloComrade, Admin, CastBallot,
                         Cinch::Plugins::UserLogin]

    # defined within the authentication extension
    c.authentication          = Cinch::Configuration::Authentication.new
    c.authentication.strategy = :login
    c.authentication.level    = :admins

    # lambdas necessary for login authentication strategy
    c.authentication.registration = lambda { |nickname, password|
      User.create :nickname => nickname, :password => password, :admin => Operators.include?(nickname)
    }
    c.authentication.fetch_user = lambda { |nickname|
      User.first :nickname => nickname
    }

    c.authentication.admins = lambda { |user| user.admin? }
    c.authentication.users  = lambda { |user| !user.admin? }
  end
end

demobot.start
