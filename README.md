# Demobot!
## Bringing democracy to IRC moderation :)

Demobot is being beta-tested in ##marxism, and is also sandboxed for testing in #demobot.

Demobot's minimum features (for freenode) currently are:

* Provide records of its own actions to users at any time. (!history and !rap_sheet)
* Allow registration of a nick in a database for channel records. (!register and !login)
* Allow registered nicks to call a vote, if they have sufficient privileges. (!accuse and !sentencing)
* Allow registered nicks to vote on operator actions. (done)
* Carry out operator actions according to the will of the people immediately. (done)
* Keep track of 'sentences' that allow scheduling of punishments, like a 3 day quiet, or a 1 day ban. (on-going)
* Set 'citizenship' model to prevent cheating the votes. (on-going)

## How does demobot work?
Demobot works in 3 phases. Accusation, sentencing, and punishment.

* a registered user calls !accuse [username of the accused] [issue], which essentially files an accusation that a rule was broken by the accused user.
* a quorum of current channel users are required to agree that a rule was broken by the accused.
* current channel users vote for what they think the appropriate punishment is for the issue (sentencing). When the quorum is reached, demobot carries out the punishment against the accused.

All actions are logged in a persisted data store, which is postgres for my implementation. Voting on behavior always has edge-cases and potential gaming. So the records exist because channel ops should look to see what was decided, and see if it needs to be overruled.

## How do I install demobot?
Currently our gem implementation is on hold to work out some cinch dependency conflicts. Your best bet is to clone this repo and bundle install.

## How do I configure demobot?
You'll need to tell demobot what channel it will be monitoring, and as a channel op you will need to give it op privileges for it to carry out punishments. Demobot can be told to which users to recognize as channel operators in config/ops.rb. If you're running demobot on heroku, you will need to [specify ENV variables](https://devcenter.heroku.com/articles/config-vars) for your database configuration, which lives in config/db.rb.

	# DB = Sequel.postgres(:host=>'localhost', :user=>'admin', :password=>'password', :database=>'demobot')
	DB = Sequel.postgres(host: ENV['DB_HOST'], user: ENV['DB_USER'], password: ENV['DB_PASSWORD'], database: ENV['DB_NAME'])

## How do I run demobot?
First you will need to set demobot's username and password in lib/demobot.rb, so it can be authenticated. To run demobot locally, use this command from the root directory of the project:

	bundle exec ruby -w lib/demobot.rb

To run your own demobot on heroku, just use the provided [Procfile](https://devcenter.heroku.com/articles/procfile).
