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
  COMMANDS = %w(help
                hello
                homo
                yolo
                current_vote
                last_vote
                #{"call_vote [nick of the perpetrator] [rule they broke, and how]"}
                close_vote
                commands
                #{"sentencing [number of ballot]"}
                #{"sentence [number of ballot] [a punishment]"}
                #{"punish [number of ballot]"}
                yay
                nay
                )
end
