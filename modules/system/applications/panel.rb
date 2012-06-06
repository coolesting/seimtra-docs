get '/system/panel' do
	opt_events :new
	slim :system_panel
end

get '/system/panel/new' do
	opt_events :save
	panel_init_fields
	slim :system_panel_form
end

get '/system/panel/edit/:pid' do
	opt_events :save
	@fields = DB[:panel].select(:pid, :menu, :name, :link, :description, :status, :level, :order).filter(:pid => params[:pid]).all[0]
 	panel_init_fields
 	slim :system_panel_form
end

#
#   here for editing
#

post '/system/panel/new' do

	panel_init_fields
	if @fields[:name] != "" and @fields[:description] != ""
		@fields.delete :bid
		DB[:panels].insert(@fields)
		redirect "/system/panel"
	else
		"The required field not be null."
	end

end

post '/system/panel/edit/:bid' do
	panel_init_fields
	if @fields[:name] != "" and @fields[:description] != "" and @fields[:bid].to_i > 0
		if DB[:panels][:bid => @fields[:bid]][:bid]
			bid = @fields.delete :bid
			DB[:panels].filter(:bid => bid.to_i).update(@fields)
			redirect "/system/panel"
		end
	else
		"The required field not be null."
	end

end

helpers do

	def panel_init_fields

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
