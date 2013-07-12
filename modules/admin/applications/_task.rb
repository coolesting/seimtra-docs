get '/admin/_task' do
	@search = _task_data.keys
	@rightbar << :search
	_task_view
end

get '/admin/_task/rm' do
	_task_rm
end

get '/admin/_task/form' do
	_task_form
end

post '/admin/_task/form' do
	_task_submit
	redirect "/admin/_task"
end

helpers do

	#get the form
	def _task_form fields = [], tpl = :_task_form
		@t[:title] 	= L[:'edit the '] + L[:'_task']
		id 			= @qs.include?(:taid) ? @qs[:taid].to_i : 0
		if id == 0
			data = _task_data
		else
			data = DB[:_task].filter(:taid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _task_view tpl = :_task_admin

		ds = DB[:_task]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:taid)
		end

		Sequel.extension :pagination
		@_task = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_task.page_count

		_tpl tpl
	end

	#submit the data
	def _task_submit fields = []
		id 	= @qs.include?(:taid) ? @qs[:taid].to_i : 0
		if id == 0
			data = _task_data
			_set_fields fields, data, true
		else
			data = DB[:_task].filter(:taid => id).first 
			_set_fields fields, data
		end
		_task_valid_fields fields

		#insert
		if id == 0
			DB[:_task].insert(@f)
		#update
		else
			DB[:_task].filter(:taid => id).update(@f)
		end
	end

	#remove the record
	def _task_rm id = 0
		if id == 0 and @qs.include?(:taid)
			id = @qs[:taid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_task].filter(:taid => id).delete
		end
		redirect back
	end

	#data construct
	def _task_data
		{
			:uid		=> _user[:uid],
			:tid		=> 1,
			:timeout		=> 1,
			:method_name		=> '',
		}
	end

	def _task_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:timeout)
			#_throw(L[:'the field cannot be empty '] + L[:'timeout']) if @f[:timeout] != 0
		end
		
		if fields.include?(:method_name)
			_throw(L[:'the field cannot be empty '] + L[:'method_name']) if @f[:method_name].strip.size < 1
		end
		
	end

end
