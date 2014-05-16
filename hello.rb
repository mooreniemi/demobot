class HelloComrade
  include Cinch::Plugin

  match "hello"

  def execute(m)
    m.reply "Zdravstvuyte tovarishch, #{m.user.nick}!"
  end
end
