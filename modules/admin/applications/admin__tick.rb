#display
get '/admin/_tick' do

	@rightbar += [:new, :search]
	ds = DB[:_tick]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:tiid => 'tiid', :uid => 'uid', :name => 'name', :agent => 'agent', :ip => 'ip', :created => 'created', }
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
 	@_tick = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_tick.page_count

	_tpl :admin__tick

end

#new a record
get '/admin/_tick/new' do

	@title = 'Create a new ticket'
	@rightbar << :save
	_tick_set_fields
	_tpl :admin__tick_form

end

post '/admin/_tick/new' do

	_tick_set_fields
	_tick_valid_fields
	
	
	DB[:_tick].insert(@fields)
	redirect "/admin/_tick"

end

#delete the record
get '/admin/_tick/rm/:tiid' do

	@title = 'Delete the _tick by id tiid, are you sure ?'
	DB[:_tick].filter(:tiid => params[:tiid].to_i).delete
	redirect "/admin/_tick"

end

#edit the record
get '/admin/_tick/edit/:tiid' do

	@title = 'Edit the ticket'
	@rightbar << :save
	@fields = DB[:_tick].filter(:tiid => params[:tiid]).all[0]
 	_tick_set_fields
 	_tpl :admin__tick_form

end

post '/admin/_tick/edit/:tiid' do

	_tick_set_fields
	_tick_valid_fields
	DB[:_tick].filter(:tiid => params[:tiid]).update(@fields)
	redirect "/admin/_tick"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _tick_set_fields
		
		default_values = {
			:uid		=> 1,
			:name		=> '',
			:agent		=> '',
			:ip		=> '',
			:created		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _tick_valid_fields
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		_throw "The agent field cannot be empty." if @fields[:agent].strip.size < 1
		
		_throw "The ip field cannot be empty." if @fields[:ip].strip.size < 1
		
		_throw "The created field cannot be empty." if @fields[:created].strip.size < 1
		
	end

end
