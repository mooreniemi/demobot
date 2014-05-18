module Punish
  include Cinch::Plugin
  include Constants

  def ban1(target)
  	channel.ban(target)
  	m.reply "#{target} has been banned."
  end

  def ban2(target)
  	pending
  end

  def ban3(target)
  	pending
  end

  def voice1(target)
  	channel.devoice(target)
  	m.reply "#{target} has been silenced."
  end

  def voice2(target)
  	pending
  end

  def voice3(target)
  	pending
  end

  def warn(target)
  	m.reply "A warning has been logged against #{target}."
  end

  def pending
  	m.reply "Unimplemented, will be time-limited."
  end
end
