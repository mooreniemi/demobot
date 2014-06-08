class Admin
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

  match /set_topic (.+)/s, method: :set_topic
  match /get_topic/s, method: :get_topic
  match /notify_ops/, method: :notify_ops
  match /history \b(\w+)\b/, method: :history
  match /rap_sheet \b(\w+)\b/, method: :rap_sheet

  def set_topic(m, topic)
    return unless authenticated? m
    m.channel.topic = "#{topic}"
  end

  def get_topic(m)
    m.reply m.channel.topic
  end

  def notify_ops(m)
    # TODO
    binding.pry
  end

  def history(m, nick)
    user = User.where(nickname: nick).first
    
    m.reply "#{m.user.nick}: #{nick} has the following records:"

    sentences = Sentence.where(user_id: user.id).count
    votes = Vote.where(user_id: user.id).count

    accused = Ballot.where(accused: user.nickname).count
    accusations = Ballot.where(initiator: user.nickname).count

    m.reply "#{votes} votes, #{sentences} sentences (against), #{accusations} accusations (by), #{accused} accusations (against)."
  end

  def rap_sheet(m, nick)
    user = User.where(nickname: nick).first

    sentences = Sentence.where(user_id: user.id)
    return m.reply "None found on #{nick}." if sentences.empty?

    m.reply "Sentences on #{nick} found:"
    sentences.each {|s| m.reply "#{Ballot[s.ballot_id].issue}"}
  end
end
