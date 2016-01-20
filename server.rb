require "sinatra/base"
require "pry"

module Forum

	class Server < Sinatra::Base

		get "/" do
			erb :index
		end

		get "/topic" do
			erb :topic
		end
			
	end

end