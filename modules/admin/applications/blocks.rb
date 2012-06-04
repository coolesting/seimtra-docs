get '/admin/blocks' do
	opt_events :new
	@title += ' the system blocks'
	@blocks = DB[:blocks]
	slim :blocks
end

get '/admin/blocks/new' do
	opt_events :save
	block_init_fields
	slim :admin_block_form
end

post '/admin/blocks/new' do

	block_init_fields
	if @fields[:name] != "" and @fields[:description] != ""
		@fields.delete :bid
		DB[:blocks].insert(@fields)
		redirect "/admin/blocks"
	else
		"The required field not be null."
	end

end

get '/admin/blocks/edit/:bid' do
	opt_events :save
	@fields = DB[:blocks].select(:bid, :name, :description, :order, :type, :display, :layout).filter(:bid => params[:bid]).all[0]
 	block_init_fields
 	slim :admin_block_form
end

post '/admin/blocks/edit/:bid' do
	block_init_fields
	if @fields[:name] != "" and @fields[:description] != "" and @fields[:bid].to_i > 0
		if DB[:blocks][:bid => @fields[:bid]][:bid]
			bid = @fields.delete :bid
			DB[:blocks].filter(:bid => bid.to_i).update(@fields)
			redirect "/admin/blocks"
		end
	else
		"The required field not be null."
	end

end

helpers do

	def block_init_fields

		[:name, :description].each do | item |
			unless @fields.include? item
				@fields[item] = params[item] ? params[item] : ""
			end
		end

		[:bid, :order].each do | item |
			unless @fields.include? item
				@fields[item] = params[item] ? params[item] : 0
			end
		end

		Sbase::Block.keys.each do | key |
			unless @fields.include? key
				@fields[key] = 0 
				if params[key]
					if Sbase::Block[key].index(params[key]) != nil
						@fields[key] = Sbase::Block[key].index(params[key])
					end
				end
			end
		end

	end

end

