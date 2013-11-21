require 'pry'

@reg_init = {} # This is a hash with methods to register commands which modules can fill on require.
# Hash must contain 'command' => block, or 'command' => [boolean, block] for exclusive_commands.

# Another hack allowing external modules/files/plugins/whatever to execute
# blocks during Cinch's initialisation block. The variable "d" should be
# Demobot's instance at that point, so they can access that one as well.
reg_cinch_init = []
@cinch_init_lambda = lambda do |block|
  reg_cinch_init.push(block)
end

def on_cinch_init(&b)
  @cinch_init_lambda.yield b
end

# Needed in voting.rb since cinch's timer requires a bot object
# Make sure to only use this once the bot has been initialised since it returns
# nil otherwise
# HACKS EVERYWHERE LA LA LA LA LAAAA
# BTW: I do not know why it has to be @@ this time, but apparently, it does.
@@get_bot_lambda = nil
def get_bot
  return @@get_bot_lambda.yield
end

#configuration can prob just be stored as json hash ultimately
#contains all the requires too
require './config/config'

d = Demobot.new()

@get_bot_lambda = "test"

c = lambda {|line, context|
  context.reply("We\'re in business! You caused this by saying #{context.params[1]}")
  }
b = lambda {|line, context|
  context.reply(Auth.authlist)
  }

d.register('test', &c)
#d.register('text', &b)
#d.register('command with spaces', &b)

@reg_init.each do |v1, v2|
  d.register(v1,&v2) unless v2.class != Proc
  d.register(v1,v2[0],&v2[1]) if v2.class == Array
end

whois = lambda {|v1,v2|
  v2.reply("You are identified as #{Auth.fetch_authname(v2.user.nick)}")
}

d.register('whois', &whois)
d.register('whoami',&whois)

ban = lambda {|v1, v2|
  channel=v2.channel
  target=v1.rstrip.split
  if target.count > 1
    v2.reply('Too many arguments')
  else
    target=v2.channel.users.keys.find {|v| v.nick==target[0]}
    v2.channel.ban(target)
  end
}
#d.register('ban', &ban)



bot = Cinch::Bot.new do
  configure do |c|
    c.nick="demobot"
    c.server = "irc.freenode.net"
    c.channels = ["#demochat"]
    c.realname = "Democracy in action"
    c.user = "demobot"
  end

  on :message, /^\s*%(\S+.*)/ do |m, command|
    d.execute(command, m)
  end

  on :private, /^%quit$/ do bot.quit end

  # TODO: Move all of these to appropriate locations via on_cinch_init

  on :leaving do |context, user| Auth::Logout.call context, user; end

  on :nick do |info|
    Auth::Nick.call info.user.last_nick, info.user.nick, info.user
  end

  # TODO: Update Resident creation code to set the activity time
  on :channel do |m|
    return unless m.channel
    db_channel = Auth::Channel[:name => m.channel.name]
    unless identity = Auth.get_identity(m.user.nick)
      Auth.noise(m.user)
    else
      db_resident = Auth::Resident[:name => identity[:content]]
      # Update last activity time
      db_resident.last_activity = Time.now.utc()
      db_resident.save
      # Update it also on authlist.
      if Auth.authlist[m.user.nick]
        Auth.authlist[m.user.nick].last_activity=db_resident.last_activity
    end
    end
  end

  # TODO: Move this as well
  timer_opts = {:interval => 60}
  voteban_update_timer = Cinch::Timer.new(self, timer_opts) do
    Voting.voteban_update()
  end
  voteban_update_timer.start

  # TODO: And this
  timer_opts = {:interval => 300} # spam every 5 mins for production
  polls_update_timer = Cinch::Timer.new(self, timer_opts) do
    Voting.polls_update()
  end
  polls_update_timer.start

  reg_cinch_init.each do |block|
    instance_eval(&block)
  end
end

@@get_bot_lambda = lambda do
  return bot
end

bot.start
