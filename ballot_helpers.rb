module BallotHelpers

  def current_ballot
    Ballot[$ballots.last(decided_at: nil)[:id]]
  end

  def last_ballot
    Ballot[$ballots.order(:decided_at).exclude(decided_at: nil)[:id]]
  end

  def get_ballot(id)
    Ballot[$ballots.where(id: id).last[:id]]
  end

  def parse_user_from(m)
    User[$users.first(nickname: m.user.nick)[:id]]
  end

  def already_cast_by?(user)
    $votes.where(user_id: user.id, ballot_id: current_ballot.id).count > 0
  end

  def dup_vote?(m)
    user = parse_user_from(m)
    already_cast_by?(user)
  end

end