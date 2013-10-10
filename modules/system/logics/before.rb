before do

	#the variable of template
	@t = {}
	@t[:title] 			= "Welcome to seimtra!"
	@t[:keywords]		= ""
	@t[:description]	= ""

	#the fields fills with form value
	@f	= {}
	#the fields fills with default value
	@fd = {}

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

	#cache
	@cache = {}
	@cache[:kv] = {}

end
