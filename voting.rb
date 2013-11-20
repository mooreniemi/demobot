module Voting

require 'sequel'
require 'cinch'

DB = Sequel.connect('sqlite://demochat.db') # DB is our database handler.
DB.run('create table if not exists votes ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key,
date datetime default(current_timestamp),
duration datetime,
type char,
initiator_id integer null,
resident_id integer null,
target char default(null),
channel_id integer not null,
state integer not null,
foreign key(channel_id) references channels(id) on delete cascade,
foreign key(resident_id) references residents(id) on delete cascade,
foreign key(initiator_id) references residents(id) on delete set null)
SQL_STMT

DB.run('create table if not exists ballots ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key,
vote_id integer not null,
resident_id integer not null,
content char,
date datetime,
foreign key(vote_id) references votes(id) on delete cascade,
foreign key(resident_id) references residents(id) on delete cascade)
SQL_STMT

DB.run('create table if not exists bans ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key,
nickname_id integer,
host_id integer,
resident_id integer,
foreign key(nickname_id) references nicknames(id) on delete cascade,
foreign key(host_id) references hosts(id) on delete cascade,
foreign key(resident_id) references residents(id) on delete cascade)
SQL_STMT

DB.run('create table if not exists bansets ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key,
ban_id integer not null,
vote_id integer not null,
foreign key(ban_id) references bans(id) on delete cascade,
foreign key(vote_id) references votes(id) on delete cascade)
SQL_STMT

class Sequel::Model
  def validates_single_non_null(columns)
    super
    columns.each do |column|
      columns.each do |other_column|
        next if column == other_column 
        if (column != nil) and (other_column != nil)
          errors.add(:column, "Non-NULL at the same time as #{other_column}")
        end
      end
    end
  end
end

class Vote < Sequel::Model(:votes)
  def validate
    super
    errors.add(:initiator, "Not a citizen") if initiator.citizens_dataset.where(:channel => channel).count!=1
  end
  one_to_many :ballots, :class => "Voting::Ballot"
  many_to_one :initiator, :class => "Auth::Resident"
  many_to_one :channel, :class => "Auth::Channel"
end

class Ballot < Sequel::Model
  def validate
    super
    errors.add(:resident, "Not a citizen") if resident.citizens_dataset.where(:channel => vote.channel).count!=1
    errors.add(:vote, "Vote no longer open") if vote.state > 0
  end
  many_to_one :vote, :class => "Voting::Vote"
  many_to_one :resident, :class => "Auth::Resident"
end

class Ban < Sequel::Model
  def validate
    super
    validates_single_non_null([:nickname_id, :host_id, :resident_id])
  end
  many_to_one :nickname, :class => "Auth::Nickname"
  many_to_one :host, :class => "Auth::Host"
  many_to_one :resident, :class => "Auth::Resident"
  one_to_one :banset, :class => "Voting::Banset"
end

class Banset < Sequel::Model
  many_to_one :ban, :class => "Voting::Ban"
  many_to_one :vote, :class => "Voting::Vote"
end

attr_accessor :latest_vote
module_function :latest_vote,:latest_vote=


# #
# Non-specific voting functions


# FIXME: determine whether this makes any sense
# Generic internal function for initiating votes
# initiator: resident object of the initiator
# target: nick (not name!) of the target
# channel: name of the channel duh
def Voting.vote_init(duration, type, initiator, target, channel, state=0)
  # Check identity
  db_channel = Auth::Channel[:name => channel]
  raise "Channel #{db_channel} unknown." unless db_channel
  raise "#{initiator} is not a citizen of #{channel}" unless Auth.resident_is_citizen?(initiator, db_channel)
  our_vote = Vote.new
  our_vote.duration = duration
  our_vote.type = type
  our_vote.initiator = initiator
  our_vote.target = target
  our_vote.channel = db_channel
  our_vote.state = state
  our_vote.save
  return our_vote
end

# TODO: actually write this one - I think it's supposed to be a generalisation
# of what we have in Voting::Yes
def Voting.cast_ballot(vote_id, originator, channel, content)
  db_resident = Auth::Resident[:name => originator]
  raise "You are not registered." unless db_resident
  db_channel = Auth::Channel[:name => channel]
  raise "No such channel." unless db_channel
  raise "You are not a citizen of this channel." unless Auth.resident_is_citizen?(db_resident, db_channel)
  db_vote = Vote[:id => vote_id]
  raise "Invalid vote id - No such voting." unless db_vote
  our_ballot = Ballot[:vote => db_vote, :resident => db_resident]
  change_existing = false
  if our_ballot
    change_existing = true
  else
    our_ballot = Ballot.new
    our_ballot.vote = db_vote
    our_ballot.resident = db_resident
  end
  our_ballot.content = content
  our_ballot.date = Time.now.utc()
  our_ballot.save
  # This shit is so inconsistent it's making me cringe:
  if change_existing
    return :changed_existing
  else
    return
  end
end

# Counts ballots and returns a hash of the form {"yes" => 10, "no" => 8, ...}
def Voting.count_ballots(vote_id)
  our_vote = Vote[:id => vote_id]
  if not our_vote
    log("No such vote. Who messed with the DB? (id => #{vote_id})", :warn)
    return
  end
  Ballot.where(:vote => our_vote).group_and_count(:content).to_hash(:content,
  :count)
end

# Get amount of users which were active in the last n seconds
def Voting.count_active_users(channel_name, seconds)
  db_channel = Auth::Channel[:name => channel_name]
  raise "No such channel." unless db_channel
  threshold = Time.now.utc() - seconds
  census = Auth::Citizen.where(:channel => db_channel)
  active_residents = Auth::Resident.where(:citizens => census).where{
  last_activity > threshold}
  return active_residents.count
end


# #
# Functions specific to certain types of votings

# Determine target for bans and quiets.
# It takes a target, which is a full nickname, and a channel name as a string.
def Voting.determine_target(target, channel)
  result = []
  if get_bot().Channel(channel).has_user?(target)
    user = get_bot().User(target)
  end
  if user
    identity = Auth.get_identity(user.nick)
    if identity
      resident = Auth::Resident[:name => identity[:content]]
      result.push(Voting::Ban.new(:resident => resident))
      Auth::Host.join(Auth::NicknameCache.where(:resident => resident).and(:host_id != nil), :host_id=>:id).all.each do |db_host|
        result.push(Voting::Ban.new(:host => db_host))
      end
      result.push(Voting::Ban.new(:host => Auth::Host.find_or_create(:host => user.host)))
    end
  else
    last=Auth::NicknameCache.join(Auth::Nickname.where(:nickname => target), :nick_id=>:id).reverse_order(:last_seen)
    if elem=last.first
      if resident=elem.resident
        result.push(Voting::Ban.new(:resident => resident))
        Auth::Host.join(Auth::NicknameCache.where(:resident => resident).and(:host_id != nil), :host_id=>:id).all.each do |db_host|
          result.push(Voting::Ban.new(:host => db_host))
        end
      else
        result.push(Voting::Ban.new(:nickname => elem.nickname))
        result.push(Voting::Ban.new(:host => elem.host))
      end
    else
      result.push(Voting::Ban.new(:nickname => Auth::Nickname.find_or_create(:nickname => target)))
    end
  end
  result.delete(nil)
  return result
end


def Voting.voteban_init(initiator, target, channel)
  duration = Time.now.utc() + $config[:voteban_voting_duration]
  target = determine_target(target,channel)
  get_bot().Channel(channel).msg("#{target}")
  vote_init(duration, "ban", initiator, target, channel)
end

# Should be called periodically to unban people whose bans have expired
def Voting.voteban_update()
  to_be_unbanned = Vote.where(:type => "banned").where{duration + \
  $config[:voteban_ban_duration] < Time.now.utc()}
  to_be_unbanned.each do |entry|
    get_bot().Channel(entry.channel[:name]).unban(entry[:target])
    entry[:type] = "ban expired"
    entry.state=4 ## Expired!
    entry.save
  end
end

Voteban = lambda do |line, context|
  begin
    args = line.split(' ')
    if args.length < 1
      context.reply("Usage: !voteban <nick>")
      return
    end
    raise "User unauthenticated" unless user_name=Auth.authlist[context.user.nick]
    db_vote = Voting.voteban_init(
     user_name, args[0], context.channel.name
    )
    context.reply("#{context.user.nick} initiated a voting to ban #{args[0]}!"\
                  " You have #{$config[:voteban_voting_duration]} seconds to"\
                  " cast your vote. ID: #{db_vote[:id]}")
    # TODO: set timer or something at this point
    # TODO: maybe move this to Voting.voteban_init since it's pretty essential
    # TODO: make this non-brainfuck
    timer_opts = {:interval => $config[:voteban_voting_duration], :shots => 1}
    vote_timer = Cinch::Timer.new(get_bot(), timer_opts) do
      ballots = Voting.count_ballots(db_vote[:id])
      context.reply("Counted votes: #{ballots}")
      active_users = Voting.count_active_users(context.channel.name, 300)
      context.reply("Active users: #{active_users}")
      total_users = context.channel.users.length
      votes_required_lambda = $config[:voteban_required_votes]
      votes_required = votes_required_lambda.call(active_users, total_users)
      context.reply("Votes required: #{votes_required}")
      success = (ballots["yes"] != nil) && (ballots["yes"] >= votes_required)
      context.reply("Vote successful: #{success}#{', commencing ban.'\
      if success}")
      # Banning for real
      if success
        context.channel.ban(db_vote.target)
        db_vote.state+=1
      else
        # 4 is for "rejected"
        db_vote.state=4
      end
      db_vote.save()
    end
    vote_timer.start
  rescue => e
    context.reply("Error: #{e}")
    raise e
  end
end

# TODO: These are mirror images of the voteban functions - refactor!
def Voting.sponsor_init(initiator, target, channel)
  duration = Time.now.utc() + $config[:sponsor_voting_duration]
  vote_init(duration, "sponsor", initiator, target, channel)
end

Sponsor = lambda do |line, context|
  begin
    raise "No such channel." unless db_channel = Auth::Channel[:name => context.channel.name]
    args = line.split(' ')
    if args.length < 1
      context.reply("Usage: !sponsor <nick>")
      return
    end
    sponsored_identity = Auth.get_identity(args[0])
    if not sponsored_identity
      raise "Who the hell is this?"
    end
    sponsored_resident = Auth::Resident[:name => sponsored_identity[:content]]
    if not sponsored_resident
      raise "Sponsored user is not registered."
    end
    if Auth::Citizen[:resident => sponsored_resident, :channel => db_channel]
      raise "Sponsored user is already a citizen of this channel."
    end
    user_name = Auth.authlist[context.user.nick]
    db_vote = Voting.sponsor_init(
     user_name, args[0], context.channel.name
    )
    db_vote.save
    context.reply("#{context.user.nick} initiated a voting to sponsor #{args[0]}!"\
                  " You have #{$config[:sponsor_voting_duration]} seconds to"\
                  " cast your vote. ID: #{db_vote[:id]}")
    # TODO: set timer or something at this point
    # TODO: maybe move this to Voting.voteban_init since it's pretty essential
    # TODO: make this non-brainfuck
    timer_opts = {:interval => $config[:sponsor_voting_duration], :shots => 1}
    vote_timer = Cinch::Timer.new(get_bot(), timer_opts) do
      ballots = Voting.count_ballots(db_vote[:id])
      context.reply("Counted votes: #{ballots}")
      active_users = Voting.count_active_users(context.channel.name, 600)
      context.reply("Active users: #{active_users}")
      total_users = context.channel.users.length
      votes_required_lambda = $config[:sponsor_required_votes]
      votes_required = votes_required_lambda.call(active_users, total_users)
      context.reply("Votes required: #{votes_required}")
      success = (ballots["yes"] != nil) && (ballots["yes"] >= votes_required)
      context.reply("Vote successful: #{success}#{', commencing '\
      'naturalisation.' if success}")
      # Granting citizenship
      if success
        Auth.make_citizen(sponsored_resident, db_channel)
        db_vote.state=1
      else
        db_vote.state=4
      end
      db_vote.save
    end
    vote_timer.start
  rescue => e
    context.reply("Error: #{e}")
    raise e
  end
end


# TODO: These are mirror images of the voteban functions - refactor!
def Voting.condemn_init(initiator, target, channel)
  duration = Time.now.utc() + $config[:condemn_voting_duration]
  vote_init(duration, "condemn", initiator, target, channel)
end

Condemn = lambda do |line, context|
  begin
    raise "No such channel" unless db_channel = Auth::Channel[:name => context.channel.name]
    args = line.split(' ')
    if args.length < 1
      context.reply("Usage: !condemn <nick>")
      return
    end
    raise "Who the hell is this?" unless condemned_identity = Auth.get_identity(args[0])
    raise "Condemned user is not registered." unless condemned_resident = Auth::Resident[:name => condemned_identity[:content]]
    condemned_citizen = condemned_resident.citizens_dataset.where(:channel => db_channel).all[0]
    if not condemned_citizen
      raise "Condemned user is not a citizen of this channel."
    end
    user_name = Auth.authlist[context.user.nick]
    db_vote = Voting.condemn_init(
     user_name, args[0], context.channel.name
    )
    db_vote.save
    context.reply("#{context.user.nick} initiated a voting to condemn #{args[0]}!"\
                  " You have #{$config[:condemn_voting_duration]} seconds to"\
                  " cast your vote. ID: #{db_vote[:id]}")
    # TODO: set timer or something at this point
    # TODO: maybe move this to Voting.voteban_init since it's pretty essential
    # TODO: make this non-brainfuck
    timer_opts = {:interval => $config[:condemn_voting_duration], :shots => 1}
    vote_timer = Cinch::Timer.new(get_bot(), timer_opts) do
      ballots = Voting.count_ballots(db_vote[:id])
      context.reply("Counted votes: #{ballots}")
      active_users = Voting.count_active_users(context.channel.name, 600)
      context.reply("Active users: #{active_users}")
      total_users = context.channel.users.length
      votes_required_lambda = $config[:condemn_required_votes]
      votes_required = votes_required_lambda.call(active_users, total_users)
      context.reply("Votes required: #{votes_required}")
      success = (ballots["yes"] != nil) && (ballots["yes"] >= votes_required)
      context.reply("Vote successful: #{success}#{', commencing '\
      'denaturalisation.' if success}")
      # Removing citizenship
      if success
        condemned_citizen.delete
        db_vote.state=1
      else
        db_vote.state=4
      end
    db_vote.save
    end
    vote_timer.start
  rescue => e
    context.reply("Error: #{e}")
    raise e
  end
end


def Voting.get_open_polls(channel)
  return Vote.where(:channel => channel, :state => 0)
end

# Should be called periodically to inform people about active polls/votings
def Voting.polls_update()
  Auth::Channel.all.each do |db_channel|
    polls = get_open_polls(db_channel)
    if not (polls.all and polls.all.length > 0)
      # Don't output anything if there isn't anyting important to say
      return
    end
    # c is the Channel object we'll be sending stuff to
    c = get_bot().Channel(db_channel[:name])
    c.send("PSA - Active polls:")
    polls.each do |p|
      ballots = Voting.count_ballots(p[:id])
      c.send("[ID: #{p[:id]}] #{p[:type].upcase} #{p[:target]} | "\
      "#{ballots}")
    end
  end
end

Polls = lambda do |line, context|
  # TODO: Make it so only citizens can do this (anti-spam)
  return if not channel = Auth::Channel[:name => context.channel.name]
  polls = Voting.get_open_polls(channel)
  if not (polls.all and polls.all.length > 0)
    context.reply("No open polls.")
    return
  end
  context.reply("Active polls:")
  polls.each do |p|
    ballots = Voting.count_ballots(p[:id])
    context.reply("[ID: #{p[:id]}] #{p[:type].upcase} #{p[:target]} | "\
    "#{ballots}")
  end
end


# Helper function for functions Yes and No so far, but it might become more
# generic in the future.
def Voting.parse_and_cast_ballot(command, line, context)
  begin
    args = line.split(' ')
    if args.length < 1
      context.reply("Usage: !#{command} <vote_id>")
      return
    end
    user_identity = Auth.get_identity(context.user.nick)
    if not user_identity
      raise "You are not a registered user."
    end
    user_name = user_identity[:content]
    channel_name = context.channel.name
    # Following line might not apply to all commands - change it then
    content = command
    result = Voting.cast_ballot(args[0], user_name, channel_name, content)
    if result == :changed_existing
      context.reply("Updated your existing vote.")
    else
      context.reply("Voting successful.")
    end
  rescue => e
    context.reply("Error: #{e}")
    raise e
  end
end


Yes = lambda do |line, context|
  Voting.parse_and_cast_ballot("yes", line, context)
end

No = lambda do |line, context|
  Voting.parse_and_cast_ballot("no", line, context)
end

end

unless @reg_init == nil
  @reg_init["gulag"] = Voting::Voteban
  @reg_init["vouch"] = Voting::Sponsor
  @reg_init["denounce"] = Voting::Condemn
  @reg_init["polls"] = Voting::Polls
  @reg_init["vote"] = Voting::Vote
  @reg_init["yes"] = Voting::Yes
  @reg_init["no"] = Voting::No
end
