get '/admin/_urul' do
	@search = _urul_data.keys
	@rightbar << :search
	_urul_view
end

get '/admin/_urul/rm' do
	_urul_rm
end

get '/admin/_urul/form' do
	_urul_form
end

post '/admin/_urul/form' do
	_urul_submit
	redirect "/admin/_urul"
end

helpers do

	#get the form
	def _urul_form fields = [], tpl = :_urul_form
		@t[:title] 	= L[:'edit the '] + L[:'_urul']
		id 			= @qs.include?(:urid) ? @qs[:urid].to_i : 0
		if id == 0
			data = _urul_data
		else
			data = DB[:_urul].filter(:urid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _urul_view tpl = :_urul_admin

		ds = DB[:_urul]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:urid)
		end

		Sequel.extension :pagination
		@_urul = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_urul.page_count

		_tpl tpl
	end

	#submit the data
	def _urul_submit fields = []
		id 	= @qs.include?(:urid) ? @qs[:urid].to_i : 0
		if id == 0
			data = _urul_data
			_set_fields fields, data, true
		else
			data = DB[:_urul].filter(:urid => id).first 
			_set_fields fields, data
		end
		_urul_valid_fields fields

		#insert
		if id == 0
			DB[:_urul].insert(@f)
		#update
		else
			DB[:_urul].filter(:urid => id).update(@f)
		end
	end

	#remove the record
	def _urul_rm id = 0
		if id == 0 and @qs.include?(:urid)
			id = @qs[:urid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_urul].filter(:urid => id).delete
		end
		redirect back
	end

	#data construct
	def _urul_data
		{
			:uid		=> _user[:uid],
			:rid		=> 1,
		}
	end

	def _urul_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
		if fields.include?(:rid)
			#_throw(L[:'the field cannot be empty '] + L[:'rid']) if @f[:rid] != 0
		end
		
	end

end
