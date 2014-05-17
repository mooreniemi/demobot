class HelloComrade
  include Cinch::Plugin

  match "hello", method: :hello
  # because LennyKitty is silly
  match "homo", method: :homo

  def hello(m)
    m.reply "Zdravstvuyte tovarishch, #{m.user.nick}!"
  end

  def homo(m)
  	m.reply "Please try to be as gay as you can, #{m.user.nick}."
  end
end
