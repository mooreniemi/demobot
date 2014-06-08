class User < Sequel::Model
  plugin :validation_helpers

  def admin?
    admin == true
  end

  # https://github.com/britishtea/cinch-authentication/blob/master/examples/user_login.rb
  def authenticate(pass)
    password == pass # Yep, very insecure.
  end

  def validate
    super
    validates_presence [:nickname]
    validates_unique [:nickname]
  end
end
