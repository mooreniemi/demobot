class Admin
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

  match /set_topic (.+)/s, :method => :set_topic
  match /get_topic/s, :method => :get_topic

  def set_topic(m, topic)
    return unless authenticated? m

    # ...
  end

  def get_topic(m)
    m.reply m.channel.topic
  end
end