require_relative 'ballot_helpers'

class Ballot < Sequel::Model
  plugin :validation_helpers
  include BallotHelpers

  one_to_many :votes

  def disciplinary?
    accused != nil
  end

  def yay_or_nay
    yay_votes > nay_votes
  end

  def votes
    yay_votes + nay_votes
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

end
