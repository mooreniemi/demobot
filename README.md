# Demobot!
## Bringing democracy to IRC moderation :)

Demobot's projected features are:

* Provide records of its own actions to users at any time. (done)
* Allow registration of a nick in a database for channel records. (done)
* Allow registered nicks to call a vote, if they have sufficient privileges. (done)
* Allow registered nicks to vote on operator actions. (done)
* Carry out operator actions according to the will of the people. (perma-ban and perma-devoice done)

## How does demobot work?
Demobot works in 3 phases. Accusation, sentencing, and punishment.

1. a registered user calls !call_vote [username] [issue], which essentially files an accusation that a rule was broken by the accused user.
2. a quorum of current channel users are required to agree that a rule was broken by the accused.
3. current channel users vote for what they think the appropriate punishment is for the issue (sentencing). When the quorum is reached, demobot carries out the punishment against the accused. 
