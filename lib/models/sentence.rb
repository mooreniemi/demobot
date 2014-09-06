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

  def over
    remove_sentence
    self.ended_at = Time.now
  end

  def release_date_now?
    self.decided_at + eval(SENTENCE_LENGTH[sentence]) < Time.now
  end

  def validate
    super
    validates_presence [:user_id]
  end

  def remove_sentence
    # TODO
  end

end
