DROP TABLE IF EXISTS users;

CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	name VARCHAR,
	email VARCHAR UNIQUE NOT NULL,
	password VARCHAR,
	avatar VARCHAR
);	

DROP TABLE IF EXISTS topics;

CREATE TABLE topics (
	id SERIAL PRIMARY KEY,
	topic_name VARCHAR,
	topic_comment VARCHAR,
	topic_score INTEGER,
	user_id INTEGER REFERENCES users (id)
);

DROP TABLE IF EXISTS comments;

CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	comment_content VARCHAR,
	user_id INTEGER REFERENCES users (id),
	topic_id INTEGER REFERENCES topics
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
	id SERIAL PRIMARY KEY,
	upvotes INTEGER,
	downvotes INTEGER,
	reply_content VARCHAR,
	user_id INTEGER REFERENCES users (id),
	comment_id INTEGER REFERENCES comments
);