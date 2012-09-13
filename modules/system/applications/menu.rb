#display
get '/system/menu' do

	sys_opt :new, :search
	ds = DB[:menu]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if settings.sys_opt.include? :search
		@search = {:name => 'name', :type => 'type', :preid => 'preid'}
	end

	@page_size = 2

	Sequel.extension :pagination
 	@menu = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @menu.page_count

	slim :system_menu

end

#new a record
get '/system/menu/new' do

	@title = 'Create a new menu.'
	sys_opt :save
	menu_set_fields
	slim :system_menu_form

end

post '/system/menu/new' do

	menu_set_fields
	menu_valid_fields
	DB[:menu].insert(@fields)
	redirect "/system/menu"

end

#delete the record
get '/system/menu/rm/:mid' do

	DB[:menu].filter(:mid => params[:mid].to_i).delete
	redirect "/system/menu"

end

#edit the record
get '/system/menu/edit/:mid' do

	@title = 'Edit the menu.'
	sys_opt :save
	@fields = DB[:menu].filter(:mid => params[:mid]).all[0]
 	menu_set_fields
 	slim :system_menu_form

end

post '/system/menu/edit/:mid' do

	menu_set_fields
	menu_valid_fields
	DB[:menu].filter(:mid => params[:mid].to_i).update(@fields)
	redirect "/system/menu"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def menu_set_fields
		
		default_values = {
			:name		=> '',
			:type		=> 'default',
			:link		=> '',
			:description=> '',
			:preid		=> 0,
			:order		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def menu_valid_fields
		
		throw_error "The name field cannot be empty." if @fields[:name] == ""
		
		throw_error "The type field cannot be empty." if @fields[:type] == ""
		
		throw_error "The link field cannot be empty." if @fields[:link] == ""
		
		throw_error "The description field cannot be empty." if @fields[:description] == ""
		
		throw_error "The preid field cannot be empty." if @fields[:preid] == ""
		
		throw_error "The order field cannot be empty." if @fields[:order] == ""
		
	end

end
