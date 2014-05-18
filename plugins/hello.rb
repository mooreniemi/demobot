class HelloComrade
  include Cinch::Plugin

  # this class is mostly for silly methods

  match "hello", method: :hello
  # because LennyKitty is silly
  match "homo", method: :homo
  
  match "yolo", method: :yolo
  match "yala", method: :yala

  def hello(m)
    m.reply "Zdravstvuyte tovarishch, #{m.user.nick}!"
  end

  def homo(m)
  	m.reply "Please try to be as gay as you can, #{m.user.nick}."
  end

  def yolo(m)
    m.reply "You should think about your life choices, #{m.user.nick}."
  end

  def yala(m)
    m.reply "I'm here for the people - MIA, interview by Miranda Sawyer of The Observer (2010)"
  end
end
