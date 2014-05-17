class Ballot < Sequel::Model
  plugin :validation_helpers

  def disciplinary?
    disciplinary == true
  end

  def validate
    super
    validates_presence [:initiator]
    #validates_unique [:nickname]
  end
end
