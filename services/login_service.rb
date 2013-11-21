class Login
  attr_accessor :user

  def initialize(line, context)
    return context.reply("Bot authentication is disabled.") unless $config[:enable_bot_auth]
    @user = context.user
    @nick = context.user.nick
    @channel = context.channel
    @user_input = line.split(" ")
    @whois = context.user.whois
    @authname = context.user.authname

    return context.reply("Usage: !register [<name>] <password>") if @user_input < 1
    return context.reply("Can't do this on the channel, you don\'t want to show your password to others.") if @channel.present?
    return context.reply("Already logged in as #{@alist[context.user.nick].name}.") if @alist.has_key?(context.user.nick)
  end

  def set_username
    if @user_input.length == 1
      login_name = @nick
      password = @user_input.first
    else
      login_name = @user_input.first
      password = @user_input.last
    end
  end

  def claim_nick
    # Dealing with nick claiming.
    #context.user.whois
    sleep(0.1) until @user.synced?(:authname)

    if @authname.present?
      begin
        match = Resident[:name => login_name]
        if match == nil or match[:password] != password
          return context.reply("Wrong name or password.")
        elsif match.identifier != 'password'
          return context.reply('Cannot reclaim network auth users.')
        end
        match.identifier=Auth.fetch_reg_date(context.user.nick)
        match.password=nil
        match.save
        @alist[context.user.nick]=match
        context.reply "Successfully claimed nick and logged in as #{login_name}."
      rescue => e
        context.reply "Error: #{e}"
        return
      end
      return
    end
  end

  def verify_nick
    context.reply("Verifying identity...")
    begin
      match = Resident[:name => login_name]
      if match == nil or match[:password] != password
        context.reply("Wrong name or password.")
        return
      elsif match.identifier!='password'
        context.reply('Authenticate to the network.')
        return
      end
      @alist[context.user.nick]=match
      context.reply "Successfully logged in as #{login_name}."
    rescue => e
      context.reply "Error: #{e}"
      return
    end
  end
end