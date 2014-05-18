require_relative 'ballot_helpers'

class CastSentence
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers
  include Constants

  # this pattern is issue id
  match /sentencing (\d+)/, method: :sentencing
  # this pattern is issue id, punishment action
  match /sentence (\d+) \b(\w+)\b/, method: :sentence

  match /sentence_count (\d+)/, method: :count_up_votes

  match /punish (\d+)/, method: :punish

  def sentencing(m, id)
    ballot = get_ballot(id)
    # TODO need to handle unregistered users more gracefully than this
    accused = User.find(nickname: ballot.accused) || User.create(nickname: ballot.accused)

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
  	sentence = get_sentence(id)
  	return m.reply "Don't be an asshole, #{m.user.nick}." unless PUNISHMENTS.include?(punishment_vote)

  	sentence.update(punishment_votes: sentence.punishment_votes + " " + punishment_vote)
    m.reply "#{m.user.nick} sentenced #{punishment_vote}."
  end

  def punish(m, id)
  	sentence = get_sentence(id)
  	punishment = sentence.count_votes
  	sentence.update(punishment: punishment)
  	m.reply "The punishment agreed on by the community was: #{punishment}"
  	# TODO
  	# call the punishment method here
  	m.reply "Actual punishment is not yet implemented, but would've happened here."
  end

  def count_up_votes(m, id)
  	sentence = get_sentence(id)
  	punishment = sentence.count_votes
  	m.reply "The sentence is: #{punishment}."
  end

end
