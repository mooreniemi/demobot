DB = Sequel.postgres(:host=>'localhost', :user=>'admin', :password=>'password', :database=>'demobot')

# sample insert
# users = DB[:users]
# users.insert(nickname: 'fuzzyhorns', password: 'pass', admin: true)

unless DB.table_exists?(:users)
	DB.create_table :users do
	  primary_key :id
	  String :nickname
	  String :password
	  Boolean :admin
	end
end
