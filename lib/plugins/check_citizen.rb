class CheckCitizenship
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  match "citizens", method: :citizens

  listen_to :private, method: :capture_nickserv

  def citizens(m)
    users = Channel(m.channel.name).users.keys
    citizens = users.inject([]) {|a,u| a << whois(u.nick) }
    # disregard demobot as a citizen
    m.reply "Total of #{citizens.count - 1} citizens"
  end

  def capture_nickserv(m)
    return unless nickserv?(m)
    citizenship = age_in_weeks(m)
    Channel('#demobot').send "#{citizenship}" if meets_minimum_weeks?(citizenship)
  end

  private

  def age_in_weeks(m)
    in_parens = get_parens_output(m.params[1])

    years = get_years(in_parens)
    years = years.empty? ? 0 : years[1..-1].to_i
    weeks = get_weeks(in_parens)
    weeks = weeks.empty? ? 0 : weeks.to_i

    (years * 52) + weeks
  end

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