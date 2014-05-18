module BallotHelpers

  def current_ballot
    return nil if $ballots.last(decided_at: nil).nil?
    Ballot[$ballots.last(decided_at: nil)[:id]]
  end

  def last_ballot
    Ballot[$ballots.exclude(decided_at: nil).order(:id).last[:id]]
  end

  def get_ballot(id)
    Ballot[$ballots.where(id: id).last[:id]]
  end

  def get_sentence(id)
    Sentence[$sentences.where(ballot_id: id).last[:id]]
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

  # TODO
  # dup_vote should really be serving both ballot and sentence, but as written it cannot
  # this whole module should probably be renamed to clearly be helpers across both ballot and sentence

  def users
    channel.users
  end

  def channel
    Channel("#demobot")
  end

  def get_mask(nick)
    channel.users.keys.select {|e| e.nick == nick}.first.mask
  end

end