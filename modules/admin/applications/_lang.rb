get '/admin/_lang' do
	@search = _lang_data.keys
	@rightbar << :search
	_lang_view
end

get '/admin/_lang/rm' do
	_lang_rm
end

get '/admin/_lang/form' do
	_lang_form
end

post '/admin/_lang/form' do
	_lang_submit
	redirect "/admin/_lang"
end

helpers do

	#get the form
	def _lang_form fields = [], tpl = :_lang_form
		@t[:title] 	= L[:'edit the '] + L[:'_lang']
		id 			= @qs.include?(:lid) ? @qs[:lid].to_i : 0
		if id == 0
			data = _lang_data
		else
			data = DB[:_lang].filter(:lid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _lang_view tpl = :_lang_admin

		ds = DB[:_lang]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:lid)
		end

		Sequel.extension :pagination
		@_lang = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_lang.page_count

		_tpl tpl
	end

	#submit the data
	def _lang_submit fields = []
		id 	= @qs.include?(:lid) ? @qs[:lid].to_i : 0
		if id == 0
			data = _lang_data
			_set_fields fields, data, true
		else
			data = DB[:_lang].filter(:lid => id).first 
			_set_fields fields, data
		end
		_lang_valid_fields fields

		#insert
		if id == 0
			DB[:_lang].insert(@f)
		#update
		else
			DB[:_lang].filter(:lid => id).update(@f)
		end
	end

	#remove the record
	def _lang_rm id = 0
		if id == 0 and @qs.include?(:lid)
			id = @qs[:lid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_lang].filter(:lid => id).delete
		end
		redirect back
	end

	#data construct
	def _lang_data
		{
			:label		=> '',
			:content		=> '',
			:uid		=> _user[:uid],
		}
	end

	def _lang_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:label)
			_throw(L[:'the field cannot be empty '] + L[:'label']) if @f[:label].strip.size < 1
		end
		
		if fields.include?(:content)
			_throw(L[:'the field cannot be empty '] + L[:'content']) if @f[:content].strip.size < 1
		end
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
	end

end
