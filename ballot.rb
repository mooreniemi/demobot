class Ballot < Sequel::Model
  plugin :validation_helpers

  # ballots should be atomic (only one in progress)
  # accept only unique logged in voters

  def disciplinary?
    accused != nil
  end

  def validate
    super
    validates_presence [:initiator]
  end
end
