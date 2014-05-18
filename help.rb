class Help
	include Cinch::Plugin
  include Constants

  match "help", method: :help
  match "vote_process", method: :vote_process
  match "feelings", method: :feelings
  match "commands", method: :commands
  match "rules", method: :rules
  match "toxic_ideologies", method: :toxic_ideologies

  def help(m)
    m.reply "#{m.user.nick}: What do you need help with? Reply with !commands, !vote_process, !rules, !toxic_ideologies, !feelings"
  end

  def commands(m)
  	m.reply "#{COMMANDS.each {|e| e.to_s}}"
  end

  def vote_process(m)
  	m.reply "#{m.user.nick}: To initialize a vote, use !call_vote [accused nick] [issue you are calling us to vote on]."
  	m.reply "An issue is an instance of rule-breaking according to our rules. Once a vote has begun, all users vote on whether they agree the rule was broken."
  	m.reply "Once 60% of the users in the channel have voted, you can close the vote using !close_vote."
  	m.reply "If people agree that your issue is a rule-breaking instance, then you can begin a punishment."
  	# TODO
  	m.reply "Punishment is not implemented yet."
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