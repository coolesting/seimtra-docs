#display
get '/admin/menu' do

	@rightbar += [:new, :search]
	ds = DB[:menu]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:name => 'name', :type => 'type', :preid => 'preid'}
	end

	#order
	if @qs[:order]
		if @qs.has_key? :desc
			ds = ds.reverse_order(@qs[:order].to_sym)
			@qs.delete :desc
		else
			ds = ds.order(@qs[:order].to_sym)
			@qs[:desc] = 'yes'
		end
	end

	Sequel.extension :pagination
 	@menu = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @menu.page_count

	sys_tpl :admin_menu

end

#new a record
get '/admin/menu/new' do

	@title = 'Create a new menu.'
	@rightbar << :save
	menu_set_fields
	sys_tpl :admin_menu_form

end

post '/admin/menu/new' do

	menu_set_fields
	menu_valid_fields
	DB[:menu].insert(@fields)
	redirect "/admin/menu"

end

#delete the record
get '/admin/menu/rm/:mid' do

	DB[:menu].filter(:mid => params[:mid].to_i).delete
	redirect "/admin/menu"

end

#edit the record
get '/admin/menu/edit/:mid' do

	@title = 'Edit the menu.'
	@rightbar << :save
	@fields = DB[:menu].filter(:mid => params[:mid]).all[0]
 	menu_set_fields
 	sys_tpl :admin_menu_form

end

post '/admin/menu/edit/:mid' do

	menu_set_fields
	menu_valid_fields
	DB[:menu].filter(:mid => params[:mid].to_i).update(@fields)
	redirect "/admin/menu"

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
		
		sys_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		sys_throw "The type field cannot be empty." if @fields[:type].strip.size < 1
		
		sys_throw "The link field cannot be empty." if @fields[:link].strip.size < 1
		
		sys_throw "The description field cannot be empty." if @fields[:description].strip.size < 1
		
		sys_throw "The preid field cannot be empty." if @fields[:preid].strip.size < 1
		
		sys_throw "The order field cannot be empty." if @fields[:order].strip.size < 1
		
	end

end
