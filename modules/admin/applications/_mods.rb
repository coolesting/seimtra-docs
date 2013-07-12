get '/admin/_mods' do
	@search = _mods_data.keys
	@rightbar << :search
	_mods_view
end

get '/admin/_mods/rm' do
	_mods_rm
end

get '/admin/_mods/form' do
	_mods_form
end

post '/admin/_mods/form' do
	_mods_submit
	redirect "/admin/_mods"
end

helpers do

	#get the form
	def _mods_form fields = [], tpl = :_mods_form
		@t[:title] 	= L[:'edit the '] + L[:'_mods']
		id 			= @qs.include?(:mid) ? @qs[:mid].to_i : 0
		if id == 0
			data = _mods_data
		else
			data = DB[:_mods].filter(:mid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _mods_view tpl = :_mods_admin

		ds = DB[:_mods]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:mid)
		end

		Sequel.extension :pagination
		@_mods = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_mods.page_count

		_tpl tpl
	end

	#submit the data
	def _mods_submit fields = []
		id 	= @qs.include?(:mid) ? @qs[:mid].to_i : 0
		if id == 0
			data = _mods_data
			_set_fields fields, data, true
		else
			data = DB[:_mods].filter(:mid => id).first 
			_set_fields fields, data
		end
		_mods_valid_fields fields

		#insert
		if id == 0
			@f[:created] = Time.now
			DB[:_mods].insert(@f)
		#update
		else
			DB[:_mods].filter(:mid => id).update(@f)
		end
	end

	#remove the record
	def _mods_rm id = 0
		if id == 0 and @qs.include?(:mid)
			id = @qs[:mid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_mods].filter(:mid => id).delete
		end
		redirect back
	end

	#data construct
	def _mods_data
		{
			:order		=> 1,
			:status		=> 1,
			:tid		=> 1,
			:name		=> '',
			:email		=> '',
			:author		=> '',
			:version		=> '',
			:description		=> '',
			:dependence		=> '',
		}
	end

	def _mods_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:order)
			#_throw(L[:'the field cannot be empty '] + L[:'order']) if @f[:order] != 0
		end
		
		if fields.include?(:status)
			#_throw(L[:'the field cannot be empty '] + L[:'status']) if @f[:status] != 0
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end

		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end

		if fields.include?(:email)
			_throw(L[:'the field cannot be empty '] + L[:'email']) if @f[:email].strip.size < 1
		end

		if fields.include?(:author)
			_throw(L[:'the field cannot be empty '] + L[:'author']) if @f[:author].strip.size < 1
		end

		if fields.include?(:version)
			_throw(L[:'the field cannot be empty '] + L[:'version']) if @f[:version].strip.size < 1
		end

		if fields.include?(:description)
			_throw(L[:'the field cannot be empty '] + L[:'description']) if @f[:description].strip.size < 1
		end

		if fields.include?(:dependence)
			_throw(L[:'the field cannot be empty '] + L[:'dependence']) if @f[:dependence].strip.size < 1
		end

	end

end
