class MakeCitizen

  def initialize(line, context)
    @initiator_identity = Auth.get_identity(context.user.nick)
    return context.reply "Couldn't verify identity." unless @initiator_identity.present?
    @initiator_resident = Resident[:name => initiator_identity[:content]]
    return context.reply "No such resident." unless @initiator_resident
    @user_input = line.split(" ")
    return context.reply "Usage: !make_citizen <registered name> <channel>" if @user_input.length < 2
    @channel_match = Channel[:name => parts[1]]
    return context.reply "No such channel." unless @channel_match.present?
    return context.reply "Not an owner or admin." unless passes_muster?
  end

  def citizenship
    begin
      @resident_match = Resident[:name => parts[0]]
      return context.reply "No such user." unless @resident_match
      Auth.make_citizen(resident_match, channel_match)
      return context.reply("#{parts[0]} is now a citizen of #{parts[1]}!")
    rescue => e
      return context.reply "Error: #{e}"
    end
  end

  private

  def passes_muster?
    return false unless Auth.resident_is_admin?(@initiator_resident, @channel_match) && $config[:bot_owners].include?(@initiator_identity[:content])
  end
end