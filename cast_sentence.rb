class CastSentence
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers
  include Constants
  include Punish

  # this pattern is issue id
  match /sentencing (\d+)/, method: :sentencing
  # this pattern is issue id, punishment action
  match /sentence (\d+) \b(\w+)\b/, method: :sentence
  # this pattern is command, issue id
  match /sentence_count (\d+)/, method: :count_up_votes
  # this pattern is command, issue id
  match /punish (\d+)/, method: :punish

  def sentencing(m, id)
    ballot = get_ballot(id)

    # TODO need to handle unregistered users more gracefully than this
    accused = User.find(nickname: ballot.accused) || User.create(nickname: ballot.accused)
    accused.update(mask: get_mask(accused.nickname)) if channel.has_user?(accused.nickname)

    case ballot.decision
    when true
    	Sentence.create(user_id: accused.id, ballot_id: ballot.id)
      m.reply "Sentencing has begun for #{id}."
      m.reply "Possible sentences are: #{PUNISHMENTS.map {|e| e.to_s}}"
    when false
      m.reply "#{id} can't be sentenced, it was not found to be a rule-breaking instance."
    else
      m.reply "#{id} is not yet ready to be sentenced."
    end
  end

  def sentence(m, id, punishment_vote)
  	return m.reply "You already voted on this punishment!" if dup_vote?(m, id, :sentence)
  	Vote.create(user_id: parse_user_from(m).id, sentence_id: id, vote: punishment_vote)

  	sentence = get_sentence(id)
  	return m.reply "Don't be an asshole, #{m.user.nick}." unless PUNISHMENTS.include?(punishment_vote)

  	sentence.update(punishment_votes: sentence.punishment_votes + " " + punishment_vote)
    m.reply "#{m.user.nick} sentenced #{punishment_vote}."
  end

  def punish(m, id)
  	sentence = get_sentence(id)

  	if quorum?(sentence.votes)
	  	punishment, target = sentence.count_votes, User[sentence.user_id]

	  	sentence.update(punishment: punishment)
	  	m.reply "The punishment agreed on by the community was: #{punishment}"

	  	send(punishment.to_sym, target) # where punishment is actually happening
	  else
	  	m.reply "Have not reached sufficient quorum to sentence."
	  end
  end

  def count_up_votes(m, id)
  	sentence = get_sentence(id)
  	punishment = sentence.count_votes
  	m.reply "The current sentence by majority is: #{punishment}."
  end

end
