get '/admin/_tags' do
	@search = _tags_data.keys
	@rightbar << :search
	_tags_view
end

get '/admin/_tags/rm' do
	_tags_rm
end

get '/admin/_tags/form' do
	_tags_form
end

post '/admin/_tags/form' do
	_tags_submit
	redirect "/admin/_tags"
end

helpers do

	#get the form
	def _tags_form fields = [], tpl = :_tags_form
		@t[:title] 	= L[:'edit the '] + L[:'_tags']
		id 			= @qs.include?(:tid) ? @qs[:tid].to_i : 0
		if id == 0
			data = _tags_data
		else
			data = DB[:_tags].filter(:tid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _tags_view tpl = :_tags_admin

		ds = DB[:_tags]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:tid)
		end

		Sequel.extension :pagination
		@_tags = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_tags.page_count

		_tpl tpl
	end

	#submit the data
	def _tags_submit fields = []
		id 	= @qs.include?(:tid) ? @qs[:tid].to_i : 0
		if id == 0
			data = _tags_data
			_set_fields fields, data, true
		else
			data = DB[:_tags].filter(:tid => id).first 
			_set_fields fields, data
		end
		_tags_valid_fields fields

		#insert
		if id == 0
			DB[:_tags].insert(@f)
		#update
		else
			DB[:_tags].filter(:tid => id).update(@f)
		end
	end

	#remove the record
	def _tags_rm id = 0
		if id == 0 and @qs.include?(:tid)
			id = @qs[:tid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_tags].filter(:tid => id).delete
		end
		redirect back
	end

	#data construct
	def _tags_data
		{
			:name		=> '',
		}
	end

	def _tags_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
	end

end
