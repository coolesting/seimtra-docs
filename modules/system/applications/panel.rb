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
	@fields = DB[:panel].filter(:pid => params[:pid]).all[0]

# 	@fields = DB[:panel].select(:pid, :menu, :name, :link, :description, :status, :order).filter(:pid => params[:pid]).all[0]

 	panel_init_fields
 	slim :system_panel_form

end

post '/system/panel/new' do

	panel_init_fields
	if @fields[:menu] != "" and @fields[:name] != "" and @fields[:link] != ""
		@fields.delete :pid
		DB[:panel].insert(@fields)
		redirect "/system/panel"
	else
		send_error 0
	end

end

post '/system/panel/edit/:pid' do

	panel_init_fields
	if @fields[:menu] != "" and @fields[:name] != "" and @fields[:link] != "" and @fields[:pid].to_i > 0
		if DB[:panel][:pid => @fields[:pid]][:pid]
			id = @fields.delete :pid
			DB[:panel].filter(:pid => id.to_i).update(@fields)
			redirect "/system/panel"
		end
	else
		send_error 0
	end

end

helpers do

	def panel_init_fields
		
		default_values = {
			:name		=> "",
			:link		=> "",
			:menu		=> "",
			:description=> "",
			:status		=> 0,
			:order		=> 1
		}

		valid_pattens = {}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

end
