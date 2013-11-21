class Register

  def initialize(line, context)
    return context.reply("Bot authentication is disabled.") unless $config[:enable_bot_auth]
    @user_input = line.split(" ")
    return context.reply("Usage: !register <name> <password>") if @user_input.length < 2
    @channel = context.channel
    return context.reply("Can't do this on the channel, you don\'t want to show your password to others.") if @channel.present?
    @user = context.user
    @authname = context.user.authname
    return context.reply "You already have network authentication." if @authname.present?
  end

  def register_nick
    #context.user.whois
    until @user.synced?(:authname)
      sleep(0.1)
    end

    context.reply("Registering #{args[0]} with password #{args[1]}...")
    begin
      our_user = Resident.new
      our_user.name=args[0]
      our_user.password=args[1]
      our_user.identifier='password'
      our_user.save
      context.reply "Successfully saved user #{args[0]} with password #{args[1]}"
    rescue => e
      return context.reply "Error on saving: #{e}"
    end
  end

end