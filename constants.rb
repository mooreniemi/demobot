module Constants

  TOXIC_IDEOLOGIES = %w(Fascism
                        Imperialism
                        Racism
                        Male chauvinism
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
                call_vote
                close_vote
                commands
                sentencing
                sentence
                punish
                yay
                nay
                )
end
