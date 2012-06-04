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

	# the fields will be inserted to table of db
	fields				= {}
	fields[:name] 		= params[:name] ? params[:name] : ""
	fields[:description] = params[:description] ? params[:description] : ""
	fields[:order] 		= params[:order] ? params[:order] : 0

	Sbase::Block.keys.each do | key |
		fields[key] = 0
		if params[key]
			unless Sbase::Block[key].index(params[key]) == nil
				 fields[key] = Sbase::Block[key].index(params[key])
			end
		end
	end

	DB[:blocks].insert(fields)

	redirect "/admin/blocks"
end

