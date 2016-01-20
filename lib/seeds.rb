require 'pg'

# if ENV["RACK_ENV"] == 'production'
# 	conn = PG.connect(
# 		dbname: ENV["POSTGRES_DB"], 
# 		host: ENV["POSTGRES_HOST"], 
# 		password: ENV["POSTGRES_PASS"], 
# 		user: ENV["POSTGRES_USER"]
# 	)
# else
# 	conn = PG.connect(dbname: "project2")
# end	

conn.exec("DROP TABLE IF EXISTS users")

conn.exec("CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR,
	email VARCHAR UNIQUE NOT NULL,
	password VARCHAR,
	avatar VARCHAR,
	)"
)

conn.exec("DROP TABLE IF EXISTS topics")

conn.exec("CREATE TABLE topics (
	id SERIAL PRIMARY KEY,
	topic_name VARCHAR,
	topic_comment VARCHAR,
	topic_score INTEGER,
	user_id INTEGER REFERENCES users
	)"
)

conn.exec("DROP TABLE IF EXISTS comments")

conn.exec("CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	comment_content VARCHAR,
	user_id INTEGER REFERENCES users,
	topic_id INTEGER REFERENCES topics
	)"
)

conn.exec("DROP TABLE IF EXISTS replies")

conn.exec("CREATE TABLE replies (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	reply_content VARCHAR,
	user_id INTEGER REFERENCES users,
	comment_id INTEGER REFERENCES comments
	)"
)