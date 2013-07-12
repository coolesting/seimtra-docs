get '/admin/_rule' do
	@search = _rule_data.keys
	@rightbar << :search
	_rule_view
end

get '/admin/_rule/rm' do
	_rule_rm
end

get '/admin/_rule/form' do
	_rule_form
end

post '/admin/_rule/form' do
	_rule_submit
	redirect "/admin/_rule"
end

helpers do

	#get the form
	def _rule_form fields = [], tpl = :_rule_form
		@t[:title] 	= L[:'edit the '] + L[:'_rule']
		id 			= @qs.include?(:rid) ? @qs[:rid].to_i : 0
		if id == 0
			data = _rule_data
		else
			data = DB[:_rule].filter(:rid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _rule_view tpl = :_rule_admin

		ds = DB[:_rule]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:rid)
		end

		Sequel.extension :pagination
		@_rule = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_rule.page_count

		_tpl tpl
	end

	#submit the data
	def _rule_submit fields = []
		id 	= @qs.include?(:rid) ? @qs[:rid].to_i : 0
		if id == 0
			data = _rule_data
			_set_fields fields, data, true
		else
			data = DB[:_rule].filter(:rid => id).first 
			_set_fields fields, data
		end
		_rule_valid_fields fields

		#insert
		if id == 0
			DB[:_rule].insert(@f)
		#update
		else
			DB[:_rule].filter(:rid => id).update(@f)
		end
	end

	#remove the record
	def _rule_rm id = 0
		if id == 0 and @qs.include?(:rid)
			id = @qs[:rid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_rule].filter(:rid => id).delete
		end
		redirect back
	end

	#data construct
	def _rule_data
		{
			:name		=> '',
		}
	end

	def _rule_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
	end

end
