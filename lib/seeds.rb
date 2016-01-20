require "pg"

conn = PG.connect(dbname: "project2")

conn.exec("CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR
	email VARCHAR UNIQUE NOT NULL,
	password VARCHAR,
	avatar VARCHAR
	)"
)

conn.exec("CREATE TABLE topics (
	id SERIAL PRIMARY KEY,
	topic_name VARCHAR,
	upvotes INTEGER,
	downvotes INTEGER,
	user_id INTEGER REFERENCES users
	)"
)

conn.exec("CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	comment_content VARCHAR,
	user_id INTEGER REFERENCES users,
	topic_id INTEGER REFERENCES topics
	)"
)

conn.exec("CREATE TABLE replies (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	reply_content VARCHAR,
	user_id INTEGER REFERENCES users,
	comment_id INTEGER REFERENCES comments
	)"
)