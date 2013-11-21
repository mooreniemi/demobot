DB = Sequel.connect('sqlite://demochat.db') # DB is our database handler.
DB.run('create table if not exists residents (id integer primary key autoincrement, name varchar(16) unique, identifier varchar(32), password varchar(64), last_activity datetime)')
DB.run('create table if not exists channels (id integer primary key autoincrement, name varchar(200) unique)')
DB.run('create table if not exists citizens ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key autoincrement,
resident_id integer not null,
channel_id integer not null,
is_admin integer,
foreign key(resident_id) references residents(id) on delete cascade,
foreign key(channel_id) references channels(id) on delete cascade)
SQL_STMT

# These are just for obscure caching purposes, don't pay too much attention to
# them as they are not essential.
DB.run('create table if not exists nicknames ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key autoincrement,
nickname varchar(16) unique)
SQL_STMT

DB.run('create table if not exists hosts ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key autoincrement,
host varchar(128) unique)
SQL_STMT

DB.run('create table if not exists nickname_caches ' +
<<SQL_STMT.gsub(/\s+/, " ").strip)
(id integer primary key autoincrement,
nickname_id integer not null,
host_id integer not null,
resident_id integer null,
last_seen datetime,
foreign key(nickname_id) references nicknames(id) on delete cascade,
foreign key(host_id) references hosts(id) on delete cascade,
foreign key(resident_id) references residents(id) on delete cascade)
SQL_STMT