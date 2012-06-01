get '/admin/blocks' do
	opt_events :new
	@title += ' the system blocks'
	@blocks = DB[:blocks]
	slim :blocks
end

get '/admin/blocks/new' do
	opt_events :save
	slim :admin_block_new
end

post '/admin/blocks/new' do
	str = ""
	params.each do | k, v |
		str += "#{k} : #{v} <br>"
	end
	str
end

