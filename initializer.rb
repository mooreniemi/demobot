require 'cinch'

# plugins
require_relative 'hello'

# bot initialized
bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.channels = ["#demobot"]
    c.plugins.plugins = [Hello]
  end
end

bot.start