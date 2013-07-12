get '/admin/_sess' do
	@search = _sess_data.keys
	@rightbar << :search
	_sess_view
end

get '/admin/_sess/rm' do
	_sess_rm
end

get '/admin/_sess/form' do
	_sess_form
end

post '/admin/_sess/form' do
	_sess_submit
	redirect "/admin/_sess"
end

helpers do

	#get the form
	def _sess_form fields = [], tpl = :_sess_form
		@t[:title] 	= L[:'edit the '] + L[:'_sess']
		id 			= @qs.include?(:sid) ? @qs[:sid].to_i : 0
		if id == 0
			data = _sess_data
		else
			data = DB[:_sess].filter(:sid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _sess_view tpl = :_sess_admin

		ds = DB[:_sess]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:sid)
		end

		Sequel.extension :pagination
		@_sess = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_sess.page_count

		_tpl tpl
	end

	#submit the data
	def _sess_submit fields = []
		id 	= @qs.include?(:sid) ? @qs[:sid].to_i : 0
		if id == 0
			data = _sess_data
			_set_fields fields, data, true
		else
			data = DB[:_sess].filter(:sid => id).first 
			_set_fields fields, data
		end
		_sess_valid_fields fields

		#insert
		if id == 0
			DB[:_sess].insert(@f)
		#update
		else
			DB[:_sess].filter(:sid => id).update(@f)
		end
	end

	#remove the record
	def _sess_rm id = 0
		if id == 0 and @qs.include?(:sid)
			id = @qs[:sid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_sess].filter(:sid => id).delete
		end
		redirect back
	end

	#data construct
	def _sess_data
		{
			:uid		=> _user[:uid],
			:timeout		=> '',
		}
	end

	def _sess_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
		if fields.include?(:timeout)
			_throw(L[:'the field cannot be empty '] + L[:'timeout']) if @f[:timeout].strip.size < 1
		end
		
	end

end
