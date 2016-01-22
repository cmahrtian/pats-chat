require 'pg'

if ENV["RACK_ENV"] == 'production'
	conn = PG.connect(
		dbname: ENV["POSTGRES_DB"], 
		host: ENV["POSTGRES_HOST"], 
		password: ENV["POSTGRES_PASS"], 
		user: ENV["POSTGRES_USER"]
	)
else
	conn = PG.connect(dbname: "project2")
end	

conn.exec("DROP TABLE IF EXISTS users CASCADE")

conn.exec("CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR,
	email VARCHAR UNIQUE NOT NULL,
	password VARCHAR,
	avatar VARCHAR
	)"
)

conn.exec("DROP TABLE IF EXISTS topics CASCADE")

conn.exec("CREATE TABLE topics (
	id SERIAL PRIMARY KEY,
	topic_name VARCHAR,
	topic_comment TEXT,
	topic_score INTEGER DEFAULT 0,
	num_comments INTEGER DEFAULT 0,
	user_id INTEGER REFERENCES users
	)"
)

conn.exec("DROP TABLE IF EXISTS comments CASCADE")

conn.exec("CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	comment_score INTEGER DEFAULT 0,
	comment_content TEXT,
	user_id INTEGER REFERENCES users,
	topic_id INTEGER REFERENCES topics
	)"
)

conn.exec("DROP TABLE IF EXISTS replies CASCADE")

conn.exec("CREATE TABLE replies (
	id SERIAL PRIMARY KEY,
	reply_score INTEGER DEFAULT 0,
	reply_content TEXT,
	user_id INTEGER REFERENCES users,
	topic_id INTEGER REFERENCES topics, 
	comment_id INTEGER REFERENCES comments
	)"
)