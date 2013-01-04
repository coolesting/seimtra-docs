#display
get '/admin/_menu' do

	@rightbar += [:new, :search]
	ds = DB[:_menu]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:mid => 'mid', :name => 'name', :link => 'link', :description => 'description', :tid => 'name', :uid => 'uid', :preid => 'preid', :order => 'order', }
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
 	@_menu = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_menu.page_count

	_tpl :admin__menu

end

#new a record
get '/admin/_menu/new' do

	@title = 'Create a new menu'
	@rightbar << :save
	_menu_set_fields
	_tpl :admin__menu_form

end

post '/admin/_menu/new' do

	_menu_set_fields
	_menu_valid_fields
	
	
	DB[:_menu].insert(@fields)
	redirect "/admin/_menu"

end

#delete the record
get '/admin/_menu/rm/:mid' do

	_msg 'Delete the _menu by id mid, are you sure ?'
	DB[:_menu].filter(:mid => params[:mid].to_i).delete
	redirect "/admin/_menu"

end

#edit the record
get '/admin/_menu/edit/:mid' do

	@title = 'Edit the menu'
	@rightbar << :save
	@fields = DB[:_menu].filter(:mid => params[:mid]).all[0]
 	_menu_set_fields
 	_tpl :admin__menu_form

end

post '/admin/_menu/edit/:mid' do

	_menu_set_fields
	_menu_valid_fields
	DB[:_menu].filter(:mid => params[:mid]).update(@fields)
	redirect "/admin/_menu"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _menu_set_fields
		
		default_values = {
			:name		=> '',
			:link		=> '',
			:description		=> '',
			:tid		=> 1,
			:uid		=> 1,
			:preid		=> 1,
			:order		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _menu_valid_fields
		
		_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		_throw "The link field cannot be empty." if @fields[:link].strip.size < 1
		
		_throw "The description field cannot be empty." if @fields[:description].strip.size < 1
		
		field = _kv :_tags, :tid, :name
		_throw "The tid field isn't existing." unless field.include? @fields[:tid].to_i

		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		#_throw "The preid field cannot be empty." if @fields[:preid] != 0
		
		#_throw "The order field cannot be empty." if @fields[:order] != 0
		
	end

end
