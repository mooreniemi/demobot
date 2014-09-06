module BallotHelpers

  def quorum?(m, votes)
    votes > minimum_voters.to_i
  end

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


  private
  def dup_vote?(m, id, type)
    user = parse_user_from(m)
    already_cast_by?(user, id, type)
  end

  def get_channel(m)
    Channel(m.channel.name)
  end

  def get_mask(m, nick)
    get_channel(m).users.keys.select {|e| e.nick == nick}.first.mask
  end

  def already_cast_by?(user, id, type)
    if type == :ballot
      $votes.where(user_id: user.id, ballot_id: id).count > 0
    else
      $votes.where(user_id: user.id, sentence_id: id).count > 0
    end
  end

  def old_enough_users
    # TODO
    # use check citizen plugin here
  end

  def minimum_voters
    # (old_enough_users * minimum_voters)
    3
  end

end
