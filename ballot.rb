class Ballot < Sequel::Model
  plugin :validation_helpers

  def disciplinary?
    accused != nil
  end

  def sufficient_votes?
    (yay_votes + nay_votes) > (users * $minimum_voters).to_i
  end

  def validate
    # TODO
    # ballots should be atomic (only one in progress)
    # accept only unique logged in voters?
    super
    validates_presence [:initiator]
    errors.add(:ballot_error, ': only one vote can proceed at a time') if unfinished_ballot_exists?
  end

  def unfinished_ballot_exists?
    $ballots.where(decided_at: nil).count > 0
  end
end
