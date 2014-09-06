module Punish
  include Cinch::Plugin
  include Constants
  
  def ban1(target, m)
    get_channel(m).ban(target)
    get_channel(m).kick(target)
    m.reply "#{target.nickname} has been banned."
  end

  def ban2(target, m)
    m.reply "Unimplemented, will be time-limited."
  end

  def ban3(target, m)
    m.reply "Unimplemented, will be time-limited."
  end

  def quiet1(target, m)
    # get_channel(m).quiet(target)
    # m.reply "#{target.nickname} has been silenced."
    m.reply "Cinch has not implemented quiets at all."
  end

  def quiet2(target, m)
    m.reply "Unimplemented, will be time-limited."
  end

  def quiet3(target, m)
    m.reply "Unimplemented, will be time-limited."
  end

  def warn(target, m)
    m.reply "A warning has been logged against #{target.nickname}."
  end

  def unban(target, m)
    get_channel(m).unban(target)
  end

  def unquiet(target, m)
    get_channel(m).unquiet(target)
  end

end
