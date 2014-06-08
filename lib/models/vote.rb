class Vote < Sequel::Model
  plugin :validation_helpers
  one_to_one :user
  one_to_one :ballot

  def validate
    super
    validates_presence [:user_id]
  end
end
