require "sinatra/base"
require "pry"

module Forum

	class Server < Sinatra::Base

		get "/" do
			erb :index
		end
			
	end

end