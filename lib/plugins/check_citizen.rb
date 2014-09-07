class CheckCitizenship
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  match "citizens", method: :citizens

  listen_to :private, method: :capture_nickserv

  def citizens(m)
    users = Channel(m.channel.name).users.keys
    citizens = users.inject([]) {|a,u| a << whois(u.nick) }
    m.reply "Total of #{citizens.count} citizens"
  end

  def capture_nickserv(m)
    return unless nickserv?(m)

    in_parens = get_parens_output(m.params[1])
    weeks = get_weeks(in_parens)
    age_in_weeks = weeks.empty? ? 0 : weeks.to_i

    Channel('#demobot').send "#{age_in_weeks}" if meets_minimum_weeks?(age_in_weeks)
  end

  private

  def get_parens_output(response)
    /\((.*?)\)/.match(response)
  end

  def get_years(in_parens)
    has_years?(in_parens) ? in_parens.to_s.split(",").reverse[3] : []
  end

  def has_years?(in_parens)
    (in_parens.to_s =~ /year/i) != nil
  end

  def get_weeks(in_parens)
    has_weeks?(in_parens) ? in_parens.to_s.split(",").reverse[2] : []
  end

  def has_weeks?(in_parens)
    (in_parens.to_s =~ /weeks/i) != nil
  end

  def meets_minimum_weeks?(weeks)
    weeks >= 8
  end

  def whois(nick)
    Target("nickserv").send "info #{nick}"
  end

  def nickserv?(m)
    (m.try(:user).try(:nick) != "NickServ") || (m.try(:bot).try(:nick) != "NickServ")
  end
end