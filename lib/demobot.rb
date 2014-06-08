require 'pry' # for debugging
require 'require_all' # for file loading

require 'cinch'
# https://github.com/britishtea/cinch-authentication/wiki/Configuration
require 'cinch/extensions/authentication'
require 'cinch/plugins/identify'
require 'sequel'

require_all 'lib/config'
require_all 'lib/helpers'
require_all 'lib/models'
require_all 'lib/plugins'

# bot initialized
$demobot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = "demobot"
    c.channels = ["#demobot", "##marxism"]
    c.plugins.plugins = [HelloComrade, Admin, CastBallot, CastSentence, Help,
                         Cinch::Plugins::UserLogin, Cinch::Plugins::Identify]

    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => "demobot",
      :password => ENV['DEMOBOT_PASSWORD'],
      :type     => :nickserv,
    }

    # defined within the authentication extension
    c.authentication          = Cinch::Configuration::Authentication.new
    c.authentication.strategy = :login
    c.authentication.level    = :admins

    # lambdas necessary for login authentication strategy
    c.authentication.registration = lambda { |nickname, password|
      User.create :nickname => nickname, :password => password,
      :admin => Operators.include?(nickname)
    }
    c.authentication.fetch_user = lambda { |nickname|
      User.first :nickname => nickname
    }

    c.authentication.admins = lambda { |user| user.admin? }
    c.authentication.users  = lambda { |user| !user.admin? }
  end
end

$demobot.start