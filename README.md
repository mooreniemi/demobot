# Demobot!
## Bringing democracy to IRC moderation :)

Demobot's minimum features (for freenode) currently are:

* Provide records of its own actions to users at any time. (!history and !rap_sheet)
* Allow registration of a nick in a database for channel records. (!register and !login)
* Allow registered nicks to call a vote, if they have sufficient privileges. (!accuse and !sentencing)
* Allow registered nicks to vote on operator actions. (done)
* Carry out operator actions according to the will of the people. (perma-ban done, quiet in progress)

## How does demobot work?
Demobot works in 3 phases. Accusation, sentencing, and punishment.

1. a registered user calls !accuse [username of the accused] [issue], which essentially files an accusation that a rule was broken by the accused user.
2. a quorum of current channel users are required to agree that a rule was broken by the accused.
3. current channel users vote for what they think the appropriate punishment is for the issue (sentencing). When the quorum is reached, demobot carries out the punishment against the accused.

All actions are logged in a persisted data store, which is postgres for my implementation. Voting on behavior always has edge-cases and potential gaming. So the records exist because channel ops should look to see what was decided, and see if it needs to be overruled.

## How do I run demobot?
Currently demobot can be deployed from your local machine or very easily on heroku. To run demobot locally, use this command from the root directory of the project:

	bundle exec ruby -w demobot.rb

To run your own demobot on heroku, make sure you set up the necessary environment variables (to connect to your db, and identify your bot on freenode).