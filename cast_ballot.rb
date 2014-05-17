class CastBallot
  include Cinch::Plugin
  include Cinch::Extensions::Authentication

  match /call_vote (.+?) (.+)/, method: :call_vote
  match "yay", method: :cast_yay
  match "nay", method: :cast_nay
  match "current_vote", method: :current_vote

  def current_vote(m)
    m.reply "The current vote is on #{get_ballot}, #{m.user.nick}"
  end

  def call_vote(m, accused = nil, issue)
    begin Ballot.create(initiator: m, accused: accused, issue: issue)
      m.reply "#{m.user.nick} proposed a vote on: #{issue}. If you agree this issue deserves an outcome vote, vote !yay now."
    rescue Exception => e
      m.reply "#{m.user.nick}: #{e}."
    end
  end

  def cast_yay(m)
    current_ballot.yay_votes += 1
    m.reply "#{m.user.nick} voted yay."
  end

  def cast_nay(m)
    current_ballot.nay_votes += 1
    m.reply "#{m.user.nick} voted nay."
  end

  def current_ballot
    $ballots.where(decided_at: nil).last
  end
end
