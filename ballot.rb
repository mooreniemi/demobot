class Ballot < Sequel::Model
  plugin :validation_helpers

  one_to_many :votes

  def disciplinary?
    accused != nil
  end

  def sufficient_votes?
    (yay_votes + nay_votes) > (channel_users * $minimum_voters).to_i
  end

  def yay_or_nay
    yay_votes > nay_votes ? 'yay' : 'nay'
  end

  def validate
    # TODO
    # accept only unique logged in voters?
    super
    validates_presence [:initiator]
    unfinished_ballot_exists? if new?
  end

  def unfinished_ballot_exists?
    errors.add(:ballot_error, ': only one vote can proceed at a time') if $ballots.where(decided_at: nil).count > 0
  end

  def channel_users
    [*$demobot.user_list].count
  end
end
