require_relative 'ballot_helpers'

class CastBallot
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  # this pattern is [nick] [however many strings you want describing the issue]
  match /call_vote \b(\w+)\b (.+)/, method: :call_vote

  match "close_vote", method: :close_vote

  match "yay", method: :cast_yay
  match "nay", method: :cast_nay

  match "current_vote", method: :current_vote
  match "last_vote", method: :last_vote

  def current_vote(m)
    if current_ballot.present?
      m.reply "#{m.user.nick}: the current ballot is #{current_ballot[:id]} on the issue '#{current_ballot[:issue]}'."
      m.reply "Ballot #{current_ballot[:id]} has #{current_ballot[:yay_votes]} yays and #{current_ballot[:nay_votes]} nays."
      m.reply "The accused for this issue is #{current_ballot[:accused]}." if current_ballot.disciplinary?
    else
      m.reply "No current ballot is open."
    end
  end

  def last_vote(m)
    # TODO doesnt currently distinguish between last decided vote and last active vote
    m.reply "The last decided vote was #{last_ballot.id} on '#{last_ballot.issue}' at #{last_ballot.decided_at}. Outcome was #{last_ballot.decision}."
  end

  def call_vote(m, accused = nil, issue)
    begin Ballot.create(initiator: m.user.nick, accused: accused, issue: issue)
      m.reply "#{m.user.nick} proposed a vote on: #{issue}. If you agree this issue deserves an outcome vote, vote !yay now."
    rescue Exception => e
      m.reply "#{m.user.nick}: #{e}."
    end
  end

  def close_vote(m)
    current_ballot.update(decision: current_ballot.yay_or_nay, decided_at: Time.now) if current_ballot.sufficient_votes?
    m.reply "#{last_ballot.id} was decided '#{last_ballot.decision}' at #{last_ballot.decided_at}."
  end

  def cast_yay(m)
    return m.reply "You already voted on this ballot!" if dup_vote?(m)
    Vote.create(user_id: parse_user_from(m).id, ballot_id: current_ballot.id, vote: 'yay')
    current_ballot.update(yay_votes: current_ballot.yay_votes + 1)
    m.reply "#{m.user.nick} voted yay."
  end

  def cast_nay(m)
    return m.reply "You already voted on this ballot!" if dup_vote?(m)
    Vote.create(user_id: parse_user_from(m).id, ballot_id: current_ballot.id, vote: 'nay')
    current_ballot.update(nay_votes: current_ballot.nay_votes + 1)
    m.reply "#{m.user.nick} voted nay."
  end

end
