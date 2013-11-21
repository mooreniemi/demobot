class Demobot
  attr_accessor :commands
  #essentially just a wrapper for the regular bot, so plugin?

  def initialize()
    @commands = CommandList.new() { |matches, line, context|
      c1 = line.partition(' ')[0]
      m2 = ''
      matches.each { |v| m2 += v += ' '}
      context.reply("Sorry, but #{c1} is ambiguous. Matches are: #{m2}")
    }
  end

  def register(*args, &b)
    @commands.register(*args, &b)
  end

  def execute(*args)
    @commands.execute(*args)
  end

  #@commands.register(*args, &b)

  def context(line, context)
    context.reply("We\'re in business! You caused this by saying #{context.params[1]}")
  end

  def auth_list(line, context)
    context.reply(Auth.authlist)
  end

  #def register(full_command, is_exclusive = false, &block)
  #d.register('test', &c)
  #d.register('text', &b)
  #d.register('command with spaces', &b)

  def sort_by_class(reg_init)
    reg_init.each do |v1, v2|
      d.register(v1,&v2) unless v2.class != Proc
      d.register(v1,v2[0],&v2[1]) if v2.class == Array
    end
  end

  def whois(v1,v2)
    v2.reply("You are identified as #{Auth.fetch_authname(v2.user.nick)}")
  end

  #d.register('whois', &whois)
  #d.register('whoami',&whois)

  def ban(v1, v2)
    channel=v2.channel
    target=v1.rstrip.split
    if target.count > 1
      v2.reply('Too many arguments')
    else
      target=v2.channel.users.keys.find {|v| v.nick==target[0]}
      v2.channel.ban(target)
    end
  end
  #d.register('ban', &ban)
end