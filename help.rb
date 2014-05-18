class Help
	include Cinch::Plugin
  include Constants

  match "help", method: :help
  match "process", method: :vote_process
  match "feelings", method: :feelings
  match "commands", method: :commands
  match "rules", method: :rules
  match "toxic_ideologies", method: :toxic_ideologies

  def help(m)
    m.reply "#{m.user.nick}: What do you need help with? Reply with !commands, !process, !rules, !toxic_ideologies, !feelings"
  end

  def commands(m)
  	m.reply "#{COMMANDS.each {|e| e.to_s}}"
  end

  def vote_process(m)
    m.reply "Demobot works through 3 phases: accusation, sentencing, punishment."
  	m.reply "#{m.user.nick}: To initialize an accusation, use !accuse [accused nick] [rule broken and how by accused (the issue)]."
  	m.reply "An issue is an instance of rule-breaking according to our rules. Once a vote has begun, all users vote on whether they agree the rule was broken."
  	m.reply "Once a quorum of the users in the channel have voted, you can close the vote using !close_vote."
  	m.reply "If people agree that your issue is a rule-breaking instance, then you can begin a punishment."
  	m.reply "Once a quorum of users in the channel have voted, you can tally the sentence using !punish."
    m.reply "Demobot will carry out the punishment and record the judgement."
  end

  def rules(m)
    m.reply "Please check out our rules here: #{RULES_URL.to_s}"
  end

  def toxic_ideologies(m)
    m.reply "#{TOXIC_IDEOLOGIES.each {|e| e.to_s}}"
  end

  def feelings(m)
  	m.reply "I love you, #{m.user.nick}. You're my favorite citizen."
  end
end