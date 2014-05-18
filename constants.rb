module Constants

  TOXIC_IDEOLOGIES = %W(Fascism
                        Imperialism
                        Racism
                        #{"Male chauvinism"}
                        Homophobia
                        Transphobia
                        Ableism)

  RULES_URL = 'http://spiritofcontradiction.eu/IRC'

  # kinda like our public api end points here
  COMMANDS = %W(help
                hello
                homo
                yolo
                current_vote
                last_vote
                #{"call_vote [nick of the perpetrator] [rule they broke, and how]"}
                close_vote
                #{"history [nick of user]"}
                commands
                #{"sentencing [number of ballot]"}
                #{"sentence [number of ballot] [a punishment]"}
                #{"punish [number of ballot]"}
                yay
                nay
                )

  PUNISHMENTS = %w(quiet1
                   quiet2
                   quiet3
                   ban1
                   ban2
                   ban3
                   warn)
end
