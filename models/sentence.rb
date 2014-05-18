class Sentence < Sequel::Model
  plugin :validation_helpers

  one_to_one :ballot
  one_to_one :user

  def count_votes
    # TODO optimize?
    # parsing the votes from a blob basically, inefficient
  	votes = punishment_votes.split(' ')
  	vote_count = votes.uniq.inject({}) {|a, e| a.merge({e => votes.count(e)})}
  	vote_count.sort.first.first
  end

  def votes
    punishment_votes.split(' ').count
  end

  def validate
    super
    validates_presence [:user_id]
  end

end
