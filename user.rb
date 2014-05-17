class User < Sequel::Model
  plugin :validation_helpers

  def admin?
  	admin == true
  end

  def validate
    super
    validates_presence [:nickname]
    validates_unique [:nickname]
  end
end