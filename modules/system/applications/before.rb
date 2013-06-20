before do

	#the title of head of html markup
	@title 			= "Welcome to seimtra!"
	@keywords		= ""
	@description	= ""

	#the fields for inserting to db
	@fields	= {}

	#request query_string
	@qs	= {}
	if qs = request.query_string
		qs.split("&").each do | item |
			key, val = item.split "="
			if val and val.index '+'
				@qs[key.to_sym] = val.gsub(/[+]/, ' ')
			else
				@qs[key.to_sym] = val
			end
		end
	end

	#the pagination parameters
	@page_count = 0
	@page_size = 30
	@page_curr = 1 
	@page_curr = @qs[:page_curr].to_i if @qs.include? :page_curr and @qs[:page_curr].to_i > 0

	#the system message
	@msg = ''
	unless request.cookies['msg'] == ''
		@msg = request.cookies['msg']
		response.set_cookie 'msg', :value => '', :path => '/'
	end

	@_tag 					= nil
	@_path					= {}

	@_path[:item]			= request.path.split '/'
	@_path[:login]			= '/_login'
	@_path[:after_login] 	= settings.home_page

end
