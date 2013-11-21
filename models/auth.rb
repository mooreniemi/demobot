class Auth
  def initialize
    @@alist={}
  end

  class Resident < Sequel::Model
    def validate
      super
      errors.add(:name, "can't be empty") if !name || name.empty?
      errors.add(:identifier, "can't be empty") if !identifier || identifier.empty?
      errors.add(:name, "#{name} is already taken") if name && new? && Resident[:name=>name]
    end
    one_to_many :citizens
    one_to_many :votes, :class => "Voting::Vote"
    one_to_many :ballots, :class => "Voting::Ballot"
    one_to_many :nickname_caches, :class => "Auth::NicknameCache"
    def to_s; return "Resident #{name}"; end;
  end

  class Channel < Sequel::Model
    def validate
      super
      errors.add(:name, "can't be empty") if !name || name.empty?
      errors.add(:name, "#{name} is already taken") if name && new? && Channel[:name=>name]
    end
    one_to_many :citizens
    one_to_many :votes, :class => "Voting::Vote"
    def to_s; return "Channel #{name}"; end;
  end

  class Citizen < Sequel::Model
    many_to_one :channel
    many_to_one :resident
    def to_s; return "Census record #{resident} on #{channel}"; end;
  end

  class Nickname < Sequel::Model
    one_to_many :nickname_cache
    def to_s; return "#{nickname}"; end;
  end

  class Host < Sequel::Model
    one_to_many :nickname_cache
    def to_s; return "#{host}"; end;
  end

  class NicknameCache < Sequel::Model
    many_to_one :nickname
    many_to_one :host
    many_to_one :resident
    def to_s; return "NicknameCache entry: #{nickname} -> #{host}, #{resident}"; end;
  end

  # Defaults for testing.
  #if Channel.count == 0
  #  c = Channel.new
  #  c.name='#demochat'
  #  c.save
  #end

  # Deletes user from alist and updates nickname cache upon logout
  def logout(context, user)
    @alist.delete(user.nick) if @alist[user.nick]
  end

  # Keeping up to date with nicks requires us to hook every time someone joins or says anything.
  def self.noise(user)
    db_resident = Auth.authlist[user.nick]
    Auth.update_nickname_cache(user.nick, user.host, db_resident)
  end

  # Gives you a hash:
  # type => :login OR :services
  # content => actual identifier
  # Returns nil if no known identity is associated with the nick
  def self.get_identity(nick)
    return nil unless s = self.authlist[nick]
    if s[:identifier]=='password'
      return {:type => :login, :content => self.authlist[nick][:name]}
    else
      return {:type => :services, :content => s[:name]}
    end
    return nil
  end

  def self.user_is_citizen?(nick, channel)
    return false unless (identity = Auth.get_identity(nick)) &&
      Citizen[:resident => Resident[:name => identity[:content]],
      :channel => Channel[:name => channel]
    ]
    return true
  end


  # Takes sequel objects, not names or anything.
  def self.resident_is_citizen?(resident, channel)
    return false unless Citizen[:resident => resident,
                          :channel => channel]
    return true
  end

  def self.resident_is_admin?(resident, channel)
    return false unless ( citizen_match = Citizen[:resident => resident,
                          :channel => channel] ) && citizen_match[:is_admin]
    return true
  end

  # Takes sequel objects, not names or anything.
  def self.make_citizen(resident, channel)
    # Check if user is already a citizen of that channel
    raise "#{resident} is already a citizen of #{channel}." if Auth.resident_is_citizen?(resident, channel)
    # No obstacles remain, time to dish out citizenships
    resident.add_citizen(:channel => channel)
    return Citizen[:channel => channel, :resident => resident]
  end


  # Updates the nickname cache (should be called upon user logout and nick change)
  # TODO: Remove redundancy without creating an "if-clause-arrow", possibly using
  # auxiliary functions for common DB operations ("update_or_create")
  def self.update_nickname_cache(nickname, host, db_resident)
    # Just checking for and creating these "auxiliary" DB entries for nick + host
    db_nickname = Nickname.find_or_create(:nickname => nickname)
    db_host = Host.find_or_create(:host => host)

    # Here comes the slightly complex part:
    # We want to update existing entries if we're dealing with "the same" user.
    # What counts as same-ness here? If the user has an associated Resident
    # object, that's all that matters, it's the same Resident. The host,
    # however, should only be taken into consideration when we do not have an
    # associated Resident object.
    # I moved the logic for all of this into the update_nickname_cache_internal
    # helper function.
    db_cache_entry = Auth.update_nickname_cache_internal(db_nickname, db_host,
    db_resident)
    # Complete cache entry with last_seen info and save.
    db_cache_entry.last_seen = Time.now.utc
    db_cache_entry.save
  end

  # Helper function to remove redundancy
  def self.update_nickname_cache_internal(db_nickname, db_host, db_resident)
    # Try matching Resident first, but only if it's not nil:
    if db_resident
      db_cache_entry = NicknameCache[:nickname => db_nickname, :resident =>
      db_resident]
      if db_cache_entry
        # Got a match, just update it:
        db_cache_entry.host = db_host
        return db_cache_entry
      end
    end

    # No match for Resident, so let's try the host, but only if there is no
    # associated Resident (otherwise two people accessing from the same
    # connection but using different accounts count as the same person):
    db_cache_entry = NicknameCache[:nickname => db_nickname, :host => db_host,
    :resident_id => nil]
    if db_cache_entry
      # Nothing to update here, just return
      return db_cache_entry
    end

    # No matches at all, we have to create a new association then:
    db_cache_entry = NicknameCache.new
    db_cache_entry.nickname = db_nickname
    db_cache_entry.host = db_host
    # db_resident may be nil, doesn't matter
    db_cache_entry.resident_id = (db_resident ? db_resident[:id] : nil)
    return db_cache_entry
  end

  def citizen_test(line, context)
    context.reply("Your identity: #{Auth.get_identity(context.user.nick)}")
    context.reply("You are #{Auth.user_is_citizen?(context.user.nick, context.channel.name) ? '' : 'not '}a citizen of this channel.")
  end

  if @reg_init.present?
    @reg_init["register"] = Auth::Register
    @reg_init["login"] = Auth::Login
    @reg_init["test_citizen"] = Auth::CitizenTest
    @reg_init["make_citizen"] = Auth::MakeCitizen
    @reg_init["make_admin"] = Auth::MakeAdmin
  end
end
