#display
get '/admin/_mods' do

	@rightbar += [:new, :search]
	ds = DB[:_mods]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:mid => 'mid', :order => 'order', :tid => 'tid', :status => 'status', :name => 'name', :email => 'email', :author => 'author', :version => 'version', :description => 'description', :dependon => 'dependon', :created => 'created', }
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
 	@_mods = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_mods.page_count

	_tpl :admin__mods

end

#new a record
get '/admin/_mods/new' do

	@title = 'Create a new module'
	@rightbar << :save
	_mods_set_fields
	_tpl :admin__mods_form

end

post '/admin/_mods/new' do

	_mods_set_fields
	_mods_valid_fields
	
	DB[:_mods].insert(@fields)
	redirect "/admin/_mods"

end

#delete the record
get '/admin/_mods/rm/:mid' do

	@title = 'Delete the _mods by id mid, are you sure ?'
	DB[:_mods].filter(:mid => params[:mid].to_i).delete
	redirect "/admin/_mods"

end

#edit the record
get '/admin/_mods/edit/:mid' do

	@title = 'Edit the module'
	@rightbar << :save
	@fields = DB[:_mods].filter(:mid => params[:mid]).all[0]
 	_mods_set_fields
 	_tpl :admin__mods_form

end

post '/admin/_mods/edit/:mid' do

	_mods_set_fields
	_mods_valid_fields
	
	DB[:_mods].filter(:mid => params[:mid]).update(@fields)
	redirect "/admin/_mods"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _mods_set_fields
		
		default_values = {
			:order		=> 1,
			:status		=> 1,
			:name		=> '',
			:tid		=> 1,
			:email		=> '',
			:author		=> '',
			:version		=> '',
			:description		=> '',
			:dependon		=> '',
			:created		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _mods_valid_fields
		
		#_throw "The order field cannot be empty." if @fields[:order] != 0
		
		field = _kv :_tags, :tid, :name
		_throw "The tid field isn't existing." unless field.include? @fields[:tid].to_i

		#_throw "The status field cannot be empty." if @fields[:status] != 0
		
		_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		_throw "The email field cannot be empty." if @fields[:email].strip.size < 1
		
		_throw "The author field cannot be empty." if @fields[:author].strip.size < 1
		
		_throw "The version field cannot be empty." if @fields[:version].strip.size < 1
		
		_throw "The description field cannot be empty." if @fields[:description].strip.size < 1
		
		#_throw "The dependon field cannot be empty." if @fields[:dependon].strip.size < 1
		
	end

end
