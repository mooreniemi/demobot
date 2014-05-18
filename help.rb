class Help
	include Cinch::Plugin

  match "help", method: :help
  match "vote_process", method: :vote_process
  match "feelings", method: :feelings

  def help(m)
    m.reply "#{m.user.nick}: What do you need help with? Reply with !commands, !vote_process, !feelings"
  end

  def commands(m)
  	# TODO
  	m.reply "This will be a list of commands."
  end

  def vote_process(m)
  	m.reply "#{m.user.nick}: To initialize a vote, use !call_vote [accused nick] [issue you are calling us to vote on]."
  	m.reply "An issue is an instance of rule-breaking according to our rules. Once a vote has begun, all users vote on whether they agree the rule was broken."
  	m.reply "Once 60% of the users in the channel have voted, you can close the vote using !close_vote."
  	m.reply "If people agree that your issue is a rule-breaking instance, then you can begin a punishment."
  	# TODO
  	m.reply "Punishment is not implemented yet."
  end

  def feelings(m)
  	m.reply "I love you, #{m.user.nick}. You're my favorite citizen."
  end
end