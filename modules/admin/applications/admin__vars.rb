#display
get '/admin/_vars' do

	@rightbar += [:new, :search]
	ds = DB[:_vars]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:vid => 'vid', :skey => 'skey', :sval => 'sval', :uid => 'uid', :changed => 'changed', }
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
 	@_vars = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_vars.page_count

	_tpl :admin__vars

end

#new a record
get '/admin/_vars/new' do

	@title = 'Create a new vars'
	@rightbar << :save
	_vars_set_fields
	_tpl :admin__vars_form

end

post '/admin/_vars/new' do

	_vars_set_fields
	_vars_valid_fields
	
	@fields[:changed] = Time.now
	
	DB[:_vars].insert(@fields)
	redirect "/admin/_vars"

end

#delete the record
get '/admin/_vars/rm/:vid' do

	@title = 'Delete the _vars by id vid, are you sure ?'
	DB[:_vars].filter(:vid => params[:vid].to_i).delete
	redirect "/admin/_vars"

end

#edit the record
get '/admin/_vars/edit/:vid' do

	@title = 'Edit the vars'
	@rightbar << :save
	@fields = DB[:_vars].filter(:vid => params[:vid]).all[0]
 	_vars_set_fields
 	_tpl :admin__vars_form

end

post '/admin/_vars/edit/:vid' do

	_vars_set_fields
	_vars_valid_fields
	@fields[:changed] = Time.now
	
	DB[:_vars].filter(:vid => params[:vid]).update(@fields)
	redirect "/admin/_vars"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _vars_set_fields
		
		default_values = {
			:skey		=> '',
			:sval		=> '',
			:uid		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _vars_valid_fields
		
		_throw "The skey field cannot be empty." if @fields[:skey].strip.size < 1
		
		_throw "The sval field cannot be empty." if @fields[:sval].strip.size < 1
		
	end

end
