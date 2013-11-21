Demochat: bringing democracy to IRC.
##############################

Our purpose is to make a plug-in for cinch which allows a channel community to rule itself, by fair principles of direct democracy, as well as dealing with emergencies, and the fact people come and go from IRC.

Requirements
##########

- Ruby 1.9.3
- require_all
- sequel
- sqlite

Starting The bot

In order to start the bot you will need to include the lib folder in rubies library path.  This can be done with the following command in sh:

export RUBYLIB=cinch/lib

The bot can then be invoked by calling: ruby run_demobot.rb

