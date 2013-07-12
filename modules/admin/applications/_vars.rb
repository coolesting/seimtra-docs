get '/admin/_vars' do
	@search = _vars_data.keys
	@rightbar << :search
	_vars_view
end

get '/admin/_vars/rm' do
	_vars_rm
end

get '/admin/_vars/form' do
	_vars_form
end

post '/admin/_vars/form' do
	_vars_submit
	redirect "/admin/_vars"
end

helpers do

	#get the form
	def _vars_form fields = [], tpl = :_vars_form
		@t[:title] 	= L[:'edit the '] + L[:'_vars']
		id 			= @qs.include?(:vid) ? @qs[:vid].to_i : 0
		if id == 0
			data = _vars_data
		else
			data = DB[:_vars].filter(:vid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _vars_view tpl = :_vars_admin

		ds = DB[:_vars]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:vid)
		end

		Sequel.extension :pagination
		@_vars = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_vars.page_count

		_tpl tpl
	end

	#submit the data
	def _vars_submit fields = []
		id 	= @qs.include?(:vid) ? @qs[:vid].to_i : 0
		if id == 0
			data = _vars_data
			_set_fields fields, data, true
		else
			data = DB[:_vars].filter(:vid => id).first 
			_set_fields fields, data
		end
		_vars_valid_fields fields

		#insert
		if id == 0
			DB[:_vars].insert(@f)
		#update
		else
			DB[:_vars].filter(:vid => id).update(@f)
		end
	end

	#remove the record
	def _vars_rm id = 0
		if id == 0 and @qs.include?(:vid)
			id = @qs[:vid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_vars].filter(:vid => id).delete
		end
		redirect back
	end

	#data construct
	def _vars_data
		{
			:skey		=> '',
			:sval		=> '',
			:description		=> '',
			:tid		=> 1,
		}
	end

	def _vars_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:skey)
			_throw(L[:'the field cannot be empty '] + L[:'skey']) if @f[:skey].strip.size < 1
		end
		
		if fields.include?(:sval)
			_throw(L[:'the field cannot be empty '] + L[:'sval']) if @f[:sval].strip.size < 1
		end
		
		if fields.include?(:description)
			_throw(L[:'the field cannot be empty '] + L[:'description']) if @f[:description].strip.size < 1
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
	end

end
