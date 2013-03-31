#display
get '/admin/_rule' do

	@rightbar += [:new, :search]
	ds = DB[:_rule]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:rid => 'rid', :name => 'name', }
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
 	@_rule = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_rule.page_count

	_tpl :admin__rule

end

#new a record
get '/admin/_rule/new' do

	@title = L[:'create a new one '] + L[:'_rule']
	@rightbar << :save
	_rule_set_fields
	_tpl :admin__rule_form

end

post '/admin/_rule/new' do

	_rule_set_fields
	_rule_valid_fields
	
	
	
	DB[:_rule].insert(@fields)
	redirect "/admin/_rule"

end

#delete the record
get '/admin/_rule/rm/:rid' do

	_msg L[:'delete the record by id '] + params[:'rid']
	DB[:_rule].filter(:rid => params[:rid].to_i).delete
	redirect "/admin/_rule"

end

#edit the record
get '/admin/_rule/edit/:rid' do

	@title = L[:'edit the '] + L[:'_rule']
	@rightbar << :save
	@fields = DB[:_rule].filter(:rid => params[:rid]).all[0]
 	_rule_set_fields
 	_tpl :admin__rule_form

end

post '/admin/_rule/edit/:rid' do

	_rule_set_fields
	_rule_valid_fields
	
	
	DB[:_rule].filter(:rid => params[:rid]).update(@fields)
	redirect "/admin/_rule"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _rule_set_fields
		
		default_values = {
			:name		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _rule_valid_fields
		
		_throw(L[:'the field cannot be empty '] + L[:'name']) if @fields[:name].strip.size < 1
		
	end

end
