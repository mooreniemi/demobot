class Nick << Auth
  def initialize(nick1, nick2, user)
    # TODO: Implement update_nickname_cache here as well, problem: No user object.
    @db_resident = @@alist[nick1]
    #may have to pass in the auth list here, but should be able to yank it as a class variable from auth

    Auth.update_nickname_cache(nick1, user.host, db_resident)
  end

  def db_resident?
    #idkr what this is doing
    @@alist[nick2] = @alist[nick1]
    @@alist.delete nick1
  end

end