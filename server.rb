require "pg"
require "sinatra/base"
require "bcrypt"
require "digest/md5"

ERRORS = { "1" => "That email already exists!" }

module Forum

	class Server < Sinatra::Base

		enable :sessions

			if ENV["RACK_ENV"] == 'production'
				@@db ||= PG.connect(
					dbname: ENV["POSTGRES_DB"], 
					host: ENV["POSTGRES_HOST"], 
					password: ENV["POSTGRES_PASS"], 
					user: ENV["POSTGRES_USER"]
				)
			else
				@@db = PG.connect(dbname: "pats_forum")
			end

		def current_user
			if session["user_id"]
				
				@user ||= @@db.exec_params(<<-SQL, [session["user_id"]]).first
					SELECT * FROM users WHERE id = $1
				SQL
			else 
				# THE USER IS NOT LOGGED IN
				{}	
			end
		end

		get "/" do
			@user = current_user
			# @topics = @@db.exec_params("SELECT * FROM users JOIN topics on users.id = topics.id ORDER BY topic_score DESC")
			@topics = @@db.exec_params("SELECT * FROM users JOIN topics on users.id = topics.user_id ORDER BY topic_score DESC")
			# ABOVE IS THE PROPER CODE FOR HEROKU
			erb :index
		end

		get "/topic" do
			@user = current_user
			erb :topic
		end

		post "/topic" do
			markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true)
    		
			@user = current_user
			topic = params[:topic]
			comment = markdown.render(params["comment"])

			@@db.exec_params("INSERT INTO topics (topic_name, topic_comment, user_id) VALUES ($1, $2, $3)", [topic, comment, @user['id']])
			@topic_comment = @@db.exec_params("SELECT * FROM topics WHERE topic_comment = $1", [comment]).first

			@contact_submitted = true
			erb :topic
		end
		
		get "/topic/:id" do
			@user = current_user
			@id = params[:id]
			@topic = @@db.exec_params("SELECT * FROM topics WHERE id = $1", [@id]).first
			@comments = @@db.exec_params("SELECT * FROM comments JOIN topics ON comments.topic_id = topics.id WHERE topics.id = #{@id}")
			@poster = @@db.exec_params("SELECT * FROM users WHERE id = #{@topic['user_id']}").first
			# @commenter = @@db.exec_params("SELECT * FROM comments JOIN users on comments.user_id = users.id WHERE comments.topic_id = #{@id}")
			erb :topic_id
		end

		get "/topic/:id/comment" do
			@user = current_user
			@id = params[:id]
			
			erb :comment
		end

		post "/topic/:id/comment" do
			markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, filter_html: true)
    		
			@user = current_user
			@id = params[:id]
			comment = markdown.render(params["comment"])

			@@db.exec_params("INSERT INTO comments (comment_content, topic_id, user_id) VALUES ($1, $2, $3)", [comment, @id, @user['id']])
			@@db.exec_params("UPDATE topics SET num_comments = num_comments + 1 WHERE id = #{@id.to_i}")

			@comment_submitted = true
			erb :comment
		end

		get "/upvote/:id" do
			@user = current_user
			@id = params[:id]
			@@db.exec_params("UPDATE topics SET topic_score = topic_score + 1 WHERE id = #{@id}")
			redirect back
		end

		get "/downvote/:id" do
			@user = current_user
			@id = params[:id]
			@@db.exec_params("UPDATE topics SET topic_score = topic_score - 1 WHERE id = #{@id}")
			redirect back
		end

		get "/signup" do
			@email_error = ERRORS[params[:e]]
			erb :signup
		end

		post "/signup" do
			encrypted_password = BCrypt::Password.create(params[:password])
			
			begin
			  users = @@db.exec_params(<<-SQL, [params[:name],params[:email],encrypted_password, params[:avatar]])
				INSERT INTO users (name, email, password, avatar) VALUES ($1, $2, $3, $4) RETURNING id; 
			  SQL
			rescue
			  redirect '/signup?e=1'
			end  		
			
			session["user_id"] = users.first['id']
			redirect "/"
			erb :index
		end

		get "/login" do
			erb :login
		end

		post "/login" do
			@user = @@db.exec_params("SELECT * FROM users WHERE email = $1", [params[:email]]).first
			if @user
				if BCrypt::Password.new(@user["password"]) == params[:password]
					session["user_id"] = @user["id"]
					@topics = @@db.exec_params("SELECT * FROM users JOIN topics on users.id = topics.id")
					redirect "/"
					erb :index
				else
					@error = "Invalid password!"
					erb :login
				end	
			else 
				@error = "Invalid email!"
				erb :login
			end
		end

		get "/logout" do
			session.clear
			redirect "/"
		end

		get "/profile/:id" do
			@user = current_user
			@id = params[:id]
			@topics = @@db.exec_params("SELECT * FROM topics WHERE user_id = #{@id}")
			@comments = @@db.exec_params("SELECT * FROM comments WHERE user_id = #{@id}")
			erb :profile
		end

	end

end