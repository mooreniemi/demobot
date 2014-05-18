class Sentence < Sequel::Model
  plugin :validation_helpers

  one_to_one :ballot
  one_to_one :user

  def validate
    super
    validates_presence [:user_id]
  end

end
