class CheckCitizenship
  include Cinch::Plugin
  include Cinch::Extensions::Authentication
  include BallotHelpers

  match "citizens", method: :citizens

  listen_to :private, method: :capture

  def citizens(m)
    users = Channel(m.channel.name).users.keys
    citizens = users.inject([]) {|a,u| a << whois(u.nick) }
    m.reply "#{citizens.count}"
  end

  def capture(m)
    in_parens = /\((.*?)\)/.match(m.params[1])
    has_weeks = has_weeks?(in_parens) ? in_parens.to_s.split(",").reverse[2] : []
    weeks = has_weeks.empty? ? 0 : has_weeks.to_i
    old = meets_minimum_weeks?(weeks) ? weeks : "x"
    Channel('#demobot').send "#{old}"
  end

  private

  def has_weeks?(in_parens)
    (in_parens.to_s =~ /weeks/i) != nil
  end

  def meets_minimum_weeks?(weeks)
    weeks >= 4
  end

  def whois(nick)
    Target("nickserv").send "info #{nick}"
  end
end