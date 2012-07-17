get '/system/menu' do
	sys_opt :new
	slim :system_menu
end

get '/system/menu/new' do
	sys_opt :save
	menu_process_fields
	slim :system_menu_form
end

get '/system/menu/edit/:mid' do

	sys_opt :save, :remove
	@fields = DB[:menu].filter(:mid => params[:mid]).all[0]

# 	@fields = DB[:menu].select(:mid, :menu, :name, :link, :description, :status, :order).filter(:mid => params[:mid]).all[0]

 	menu_process_fields
 	slim :system_menu_form

end

post '/system/menu/new' do

	menu_process_fields

	DB[:menu].insert(@fields)

	redirect "/system/menu"

end

post '/system/menu/edit/:mid' do

	menu_process_fields

	dataset = DB[:menu].filter(:mid => params[:mid].to_i)

	if dataset
		if params[:opt] == "Remove"
			dataset.delete
		elsif params[:opt] == "Save"
			dataset.update(@fields)
		end
	end

	redirect "/system/menu"

end

helpers do

	def menu_process_fields data = {}

		default_values = {
			:name			=> "",
			:link			=> "",
			:description	=> "",
			:preid			=> 0,
			:order			=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

		unless data.empty?

			if data.include? :no_null
				data[:no_null].each do | field |
					throw_error "The #{fields} can not be empty." if field == ""
				end
			end

		end

	end

end
