module Punish
  include Cinch::Plugin
  include Constants

  PENDING =	m.reply "Unimplemented, will be time-limited."
  
  def ban1(target)
    channel.ban(target)
    m.reply "#{target} has been banned."
  end

  def ban2(target)
    PENDING
  end

  def ban3(target)
    PENDING
  end

  def voice1(target)
    channel.devoice(target)
    m.reply "#{target} has been silenced."
  end

  def voice2(target)
    PENDING
  end

  def voice3(target)
    PENDING
  end

  def warn(target)
    m.reply "A warning has been logged against #{target}."
  end

end
