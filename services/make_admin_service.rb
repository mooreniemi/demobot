class MakeAdmin

  def initialize(line, context)
    return unless initiator_identity = Auth.get_identity(context.user.nick)
    return unless $config[:bot_owners].include?(initiator_identity[:content])
    @user_input = line.split(" ")
    return context.reply "Usage: !make_admin <registered name> <channel>" if @user_input < 2
    @channel_match = Channel[:name => parts[1]]
    return context.reply "No such channel." unless @channel_match.present?
    @resident_match = Resident[:name => parts[0]]
    return context.reply "No such user." unless @resident_match.present?
    @citizen_match = check_citizen_match
  end

  private

  def check_citizen_match
    citizen = Citizen[:resident_id => resident_match[:id], :channel_id => channel_match[:id]]
    return citizen if citizen.present?

    begin
      return citizen = Auth.make_citizen(@resident_match, @channel_match)
    rescue => e
      context.reply "This should NEVER happen the universe broke oh no oh fuck"
    end

  end

end
