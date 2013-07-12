get '/admin/_docs' do
	@search = _docs_data.keys
	@rightbar << :search
	_docs_view
end

get '/admin/_docs/rm' do
	_docs_rm
end

get '/admin/_docs/form' do
	_docs_form
end

post '/admin/_docs/form' do
	_docs_submit
	redirect "/admin/_docs"
end

helpers do

	#get the form
	def _docs_form fields = [], tpl = :_docs_form
		@t[:title] 	= L[:'edit the '] + L[:'_docs']
		id 			= @qs.include?(:doid) ? @qs[:doid].to_i : 0
		if id == 0
			data = _docs_data
		else
			data = DB[:_docs].filter(:doid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _docs_view tpl = :_docs_admin

		ds = DB[:_docs]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:doid)
		end

		Sequel.extension :pagination
		@_docs = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_docs.page_count

		_tpl tpl
	end

	#submit the data
	def _docs_submit fields = []
		id 	= @qs.include?(:doid) ? @qs[:doid].to_i : 0
		if id == 0
			data = _docs_data
			_set_fields fields, data, true
		else
			data = DB[:_docs].filter(:doid => id).first 
			_set_fields fields, data
		end
		_docs_valid_fields fields

		#insert
		if id == 0
			@f[:created] = Time.now
			DB[:_docs].insert(@f)
		#update
		else
			DB[:_docs].filter(:doid => id).update(@f)
		end
	end

	#remove the record
	def _docs_rm id = 0
		if id == 0 and @qs.include?(:doid)
			id = @qs[:doid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_docs].filter(:doid => id).delete
		end
		redirect back
	end

	#data construct
	def _docs_data
		{
			:uid		=> _user[:uid],
			:tid		=> 1,
			:name		=> '',
			:body		=> '',
		}
	end

	def _docs_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
		if fields.include?(:body)
			_throw(L[:'the field cannot be empty '] + L[:'body']) if @f[:body].strip.size < 1
		end
		
		if fields.include?(:created)
			_throw(L[:'the field cannot be empty '] + L[:'created']) if @f[:created].strip.size < 1
		end
		
	end

end
