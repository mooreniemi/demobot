DB = Sequel.postgres(:host=>'localhost', :user=>'admin', :password=>'password', :database=>'demobot')

# sample insert
# users.insert(nickname: 'fuzzyhorns', password: 'pass', admin: true)

$users = DB[:users]
$ballots = DB[:ballots].order(:initiated_at)

unless DB.table_exists?(:users)
	DB.create_table :users do
	  primary_key :id
	  String :nickname
	  String :password
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
	  Integer :yay_votes, default: 0
	  Integer :nay_votes, default: 0
	end
end

# sample column adds
# DB.add_column :ballots, :initiated_at, :datetime, :default => Time.now
# DB.add_column :ballots, :decided_at, :datetime