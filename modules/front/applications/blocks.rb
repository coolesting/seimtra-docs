get '/system/block' do
	opt_events :new
	@blocks = DB[:block]
	slim :system_block
end

get '/system/block/new' do
	opt_events :save
	block_init_fields
	slim :system_block_form
end

post '/system/block/new' do

	block_init_fields
	if @fields[:name] != "" and @fields[:description] != ""
		@fields.delete :bid
		DB[:block].insert(@fields)
		redirect "/system/block"
	else
		"The required field not be null."
	end

end

get '/system/block/edit/:bid' do
	opt_events :save
	@fields = DB[:block].select(:bid, :name, :description, :order, :type, :display, :layout).filter(:bid => params[:bid]).all[0]
 	block_init_fields
 	slim :system_block_form
end

post '/system/block/edit/:bid' do
	block_init_fields
	if @fields[:name] != "" and @fields[:description] != "" and @fields[:bid].to_i > 0
		if DB[:block][:bid => @fields[:bid]][:bid]
			bid = @fields.delete :bid
			DB[:block].filter(:bid => bid.to_i).update(@fields)
			redirect "/system/block"
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
				@fields[item] = params[item] ? params[item] : 1
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

