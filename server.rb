require "pg"
require "sinatra/base"
require "pry"

module Forum

	class Server < Sinatra::Base

		db = PG.connect(dbname: "pats_forum")

		get "/" do
			@topics = db.exec_params("SELECT * FROM users JOIN topics on users.id = topics.id")
			erb :index
		end

		get "/topic" do
			erb :topic
		end

		post "/topic" do
			name = params[:name]
			email = params[:email]
			topic = params[:topic]
			comment = params[:comment]

			db.exec_params("INSERT INTO topics (topic_name, topic_comment) VALUES ($1, $2)", [topic, comment])
			db.exec_params("INSERT INTO users (name, email) VALUES ($1, $2)", [name, email])

			@contact_submitted = true
			erb :topic
		end
		
		get "/topic/:id" do
			@id = params[:id]
			@topic = db.exec_params("SELECT * FROM users JOIN topics ON users.id = topics.id WHERE topics.id = #{@id.to_i}").first
			erb :topic_id
		end

		get "/topic/:id/comment" do
			erb :comment
		end

	end

end