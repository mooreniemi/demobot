DB = Sequel.sqlite # memory database

DB.create_table :users do
  primary_key :id
  String :nickname
  Boolean :admin
end