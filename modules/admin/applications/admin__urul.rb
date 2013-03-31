#display
get '/admin/_urul' do

	@rightbar += [:new, :search]
	ds = DB[:_urul]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:urid => 'urid', :uid => 'uid', :rid => 'name', }
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
 	@_urul = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_urul.page_count

	_tpl :admin__urul

end

#new a record
get '/admin/_urul/new' do

	@title = L[:'create a new one '] + L[:'_urul']
	@rightbar << :save
	_urul_set_fields
	_tpl :admin__urul_form

end

post '/admin/_urul/new' do

	_urul_set_fields
	_urul_valid_fields
	
	
	
	DB[:_urul].insert(@fields)
	redirect "/admin/_urul"

end

#delete the record
get '/admin/_urul/rm/:urid' do

	_msg L[:'delete the record by id '] + params[:'urid']
	DB[:_urul].filter(:urid => params[:urid].to_i).delete
	redirect "/admin/_urul"

end

#edit the record
get '/admin/_urul/edit/:urid' do

	@title = L[:'edit the '] + L[:'_urul']
	@rightbar << :save
	@fields = DB[:_urul].filter(:urid => params[:urid]).all[0]
 	_urul_set_fields
 	_tpl :admin__urul_form

end

post '/admin/_urul/edit/:urid' do

	_urul_set_fields
	_urul_valid_fields
	
	
	DB[:_urul].filter(:urid => params[:urid]).update(@fields)
	redirect "/admin/_urul"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _urul_set_fields
		
		default_values = {
			:uid		=> _user[:uid],
			:rid		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _urul_valid_fields
		
		#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @fields[:uid] != 0
		
		field = _kv :_rule, :rid, :name
					
		_throw(L[:'the field does not exist '] + L[:'rid']) unless field.include? @fields[:rid].to_i
	end

end
