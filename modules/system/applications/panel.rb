get '/system/panel' do
	opt_events :new
	slim :system_panel
end

get '/system/panel/new' do
	opt_events :save
	panel_process_fields
	slim :system_panel_form
end

get '/system/panel/edit/:pid' do

	opt_events :save, :remove
	@fields = DB[:panel].filter(:pid => params[:pid]).all[0]

# 	@fields = DB[:panel].select(:pid, :menu, :name, :link, :description, :status, :order).filter(:pid => params[:pid]).all[0]

 	panel_process_fields
 	slim :system_panel_form

end

post '/system/panel/new' do

	panel_process_fields :valid
	@fields.delete :pid
	DB[:panel].insert(@fields)
	redirect "/system/panel"

end

post '/system/panel/edit/:pid' do

	panel_process_fields :valid

	if params[:opt] == "Remove"
		DB[:panel].delete(:pid => @fields[:pid])
	elsif params[:opt] == "Save"
		id = @fields.delete :pid
		DB[:panel].filter(:pid => id.to_i).update(@fields)
	end
	redirect "/system/panel"


end

helpers do

	def panel_process_fields opt = :init, data = {}
		
		if opt == :valid

			valid_pattens = {}

			if DB[:panel][:pid => @fields[:pid]][:pid]
			end
		
		elsif opt == :init

			default_values = {
				:name		=> "",
				:link		=> "",
				:menu		=> "",
				:description=> "",
				:status		=> 0,
				:order		=> 1
			}


			default_values.each do | k, v |
				unless @fields.include? k
					@fields[k] = params[k] ? params[k] : v
				end
			end

		end

	end

end
