class CastBallot
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  # this pattern is [nick] [however many strings you want describing the issue]
  match /accuse \b(\w+)\b (.+)/, method: :call_vote

  match "close_vote", method: :close_vote

  match "yay", method: :cast_yay
  match "nay", method: :cast_nay

  match "current_vote", method: :current_vote
  match "last_vote", method: :last_vote

  def current_vote(m)
    unless current_ballot == nil
      m.reply "#{m.user.nick}: the current ballot is #{current_ballot[:id]} on the issue of #{current_ballot[:accused]} accused of '#{current_ballot[:issue]}'."
      m.reply "Ballot #{current_ballot[:id]} has #{current_ballot[:yay_votes]} yays and #{current_ballot[:nay_votes]} nays."
    else
      m.reply "No current ballot is open. If you want to propose one, use !call_vote [accused nickname] [issue description]."
    end
  end

  def last_vote(m)
    m.reply "The last decided vote was #{last_ballot.id} on '#{last_ballot.issue}' at #{last_ballot.decided_at}. Outcome was #{last_ballot.decision}."
  end

  def call_vote(m, accused = nil, issue)
    begin Ballot.create(initiator: m.user.nick, accused: accused, issue: issue)
      m.reply "#{m.user.nick} accused #{accused} of: #{issue}. If you agree this issue deserves a sentencing vote, vote !yay now."
    rescue Exception => e
      m.reply "#{m.user.nick}: #{e}."
    end
  end

  def close_vote(m)
    if quorum?(m, current_ballot.votes)
      current_ballot.update(decision: current_ballot.yay_or_nay, decided_at: Time.now)
      m.reply "#{last_ballot.id} was decided '#{last_ballot.decision}' at #{last_ballot.decided_at}."
    else
      m.reply "Insufficient votes to close."
    end
  end

  def cast_yay(m)
    return m.reply "Only registered users may vote, #{m.user.nick}. See !registration for more details." if User.where(nickname: m.user.nick).empty?
    return m.reply "#{m.user.nick}: You already voted on this ballot!" if dup_vote?(m, current_ballot.id, :ballot)
    Vote.create(user_id: parse_user_from(m).id, ballot_id: current_ballot.id, vote: 'yay')
    current_ballot.update(yay_votes: current_ballot.yay_votes + 1)
    m.reply "#{m.user.nick} voted yay."
  end

  def cast_nay(m)
    return m.reply "Only registered users may vote, #{m.user.nick}. See !registration for more details." if User.where(nickname: m.user.nick).empty?
    return m.reply "#{m.user.nick}: You already voted on this ballot!" if dup_vote?(m, current_ballot.id, :ballot)
    Vote.create(user_id: parse_user_from(m).id, ballot_id: current_ballot.id, vote: 'nay')
    current_ballot.update(nay_votes: current_ballot.nay_votes + 1)
    m.reply "#{m.user.nick} voted nay."
  end

end
