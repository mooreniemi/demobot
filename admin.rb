class Admin
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

  match /set_topic (.+)/s, method: :set_topic
  match /get_topic/s, method: :get_topic
  match /notify_ops/, method: :notify_ops
  match /history (.+)/, method: :history

  def set_topic(m, topic)
    return unless authenticated? m
    m.channel.topic = "#{topic}"
  end

  def get_topic(m)
    m.reply m.channel.topic
  end

  def notify_ops(m)
    # TODO
  end

  def history(m, nick)
    m.reply "#{m}: #{nick} has the following records."
    user = User.where(nickname: nick)
  end
end
