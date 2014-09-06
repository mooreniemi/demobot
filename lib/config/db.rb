# locally this is
# DB = Sequel.postgres(:host=>'localhost', :user=>'admin', :password=>'password', :database=>'demobot')
DB = Sequel.postgres(host: ENV['DB_HOST'], user: ENV['DB_USER'], password: ENV['DB_PASSWORD'], database: ENV['DB_NAME'])

# sample insert
# users.insert(nickname: 'fuzzyhorns', password: 'pass', admin: true)

$users = DB[:users]
$ballots = DB[:ballots].order(:initiated_at)
$votes = DB[:votes]
$sentences = DB[:sentences].order(:ballot_id)

# for our rake task, aka the parol board
$unended_sentences = $sentences.where(ended_at: nil)

unless DB.table_exists?(:users)
  DB.create_table :users do
    primary_key :id
    String :nickname
    String :password
    String :mask
    Boolean :admin
  end
end

unless DB.table_exists?(:ballots)
  DB.create_table :ballots do
    primary_key :id
    String :issue
    String :initiator
    String :accused
    DateTime :initiated_at, default: Time.now
    DateTime :decided_at
    Boolean :decision
    Boolean :sentenced
    Integer :yay_votes, default: 0
    Integer :nay_votes, default: 0
  end
end

unless DB.table_exists?(:votes)
  DB.create_table :votes do
    primary_key :id
    Integer :user_id
    Integer :ballot_id
    Integer :sentence_id
    String :vote
  end
end

unless DB.table_exists?(:sentences)
  DB.create_table :sentences do
    primary_key :id
    DateTime :decided_at
    DateTime :ended_at
    Integer :user_id
    Integer :ballot_id
    String :punishment_votes, default: ''
    String :punishment
  end
end

# sample column adds
# DB.add_column :ballots, :initiated_at, :datetime, :default => Time.now
# DB.add_column :users, :mask, :string
