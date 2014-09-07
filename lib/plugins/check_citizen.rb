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
    Channel('#demobot').send "#{in_parens}"
  end

  private

  def whois(nick)
    Target("nickserv").send "info #{nick}"
  end
end