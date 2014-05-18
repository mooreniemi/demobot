require_relative 'ballot_helpers'

class CastSentence
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  # this pattern is issue id
  match /sentencing (\d+)/, method: :sentencing
  # this pattern is issue id, punishment action
  match /sentence (\d+) \b(\w+)\b/, method: :sentence

  match /sentence_count (\d+)/, method: :count_up_votes

  match /punish (\d+)/, method: :punish

  def sentencing(m, id)
    ballot = get_ballot(id)
    accused = User.find(nickname: ballot.accused)

    case ballot.decision
    when true
    	Sentence.create(user_id: accused.id, ballot_id: ballot.id)
      m.reply "Sentencing has begun for #{id}."
      m.reply "Possible sentences are: #{punishments.map {|e| e.to_s}}"
    when false
      m.reply "#{id} can't be sentenced, it was not found to be a rule-breaking instance."
    else
      m.reply "#{id} is not yet ready to be sentenced."
    end
  end

  def sentence(m, id, punishment_vote)
  	sentence = get_sentence(id)
  	return m.reply "Don't be an asshole, #{m.user.nick}." unless punishments.include?(punishment_vote)

  	sentence.update(punishment_votes: sentence.punishment_votes + " " + punishment_vote)
    m.reply "#{m.user.nick} sentenced #{punishment_vote}."
  end

  def punish(m, id)

  end

  def count_up_votes(m, id)
  	sentence = get_sentence(id)
  	punishment = sentence.count_votes
  	m.reply "The sentence is: #{punishment}."
  end

  def punishments
  	%w(voice1 voice2 voice3 ban1 ban2 ban3 warn)
  end
end
