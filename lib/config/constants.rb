module Constants
  # channel specific, these are particular to ##marxism
  # possibly in the future could make a call to a URL and parse those
  TOXIC_IDEOLOGIES = %W(Fascism
                        Imperialism
                        Racism
                        #{"Male chauvinism"}
                        Homophobia
                        Transphobia
                        Ableism)

  # channel rules
  RULES_URL = 'http://spiritofcontradiction.eu/IRC'

  # TODO not self-documenting
  COMMANDS = %W(help
                hello
                homo
                yolo
                current_vote
                last_vote
                #{"accuse [nick of the perpetrator] [rule they broke, and how]"}
                close_vote
                #{"history [nick of user]"}
                commands
                #{"sentencing [number of ballot]"}
                #{"sentence [number of ballot] [a punishment]"}
                #{"punish [number of ballot]"}
                yay
                nay)

  # 2 & 3 remain unimplemented
  PUNISHMENTS = %w(quiet1
                   quiet2
                   quiet3
                   ban1
                   ban2
                   ban3
                   warn)
end
