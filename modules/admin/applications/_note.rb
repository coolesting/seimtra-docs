get '/admin/_note' do
	@search = _note_data.keys
	@rightbar << :search
	_note_view
end

get '/admin/_note/rm' do
	_note_rm
end

get '/admin/_note/form' do
	_note_form
end

post '/admin/_note/form' do
	_note_submit
	redirect "/admin/_note"
end

helpers do

	#get the form
	def _note_form fields = [], tpl = :_note_form
		@t[:title] 	= L[:'edit the '] + L[:'_note']
		id 			= @qs.include?(:nid) ? @qs[:nid].to_i : 0
		if id == 0
			data = _note_data
		else
			data = DB[:_note].filter(:nid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _note_view tpl = :_note_admin

		ds = DB[:_note]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:nid)
		end

		Sequel.extension :pagination
		@_note = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_note.page_count

		_tpl tpl
	end

	#submit the data
	def _note_submit fields = []
		id 	= @qs.include?(:nid) ? @qs[:nid].to_i : 0
		if id == 0
			data = _note_data
			_set_fields fields, data, true
		else
			data = DB[:_note].filter(:nid => id).first 
			_set_fields fields, data
		end
		_note_valid_fields fields

		#insert
		if id == 0
			@f[:created] = Time.now
			DB[:_note].insert(@f)
		#update
		else
			DB[:_note].filter(:nid => id).update(@f)
		end
	end

	#remove the record
	def _note_rm id = 0
		if id == 0 and @qs.include?(:nid)
			id = @qs[:nid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_note].filter(:nid => id).delete
		end
		redirect back
	end

	#data construct
	def _note_data
		{
			:from_uid		=> 1,
			:to_uid		=> 1,
			:mark		=> '',
			:tid		=> 1,
			:content		=> '',
		}
	end

	def _note_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:from_uid)
			#_throw(L[:'the field cannot be empty '] + L[:'from_uid']) if @f[:from_uid] != 0
		end
		
		if fields.include?(:to_uid)
			#_throw(L[:'the field cannot be empty '] + L[:'to_uid']) if @f[:to_uid] != 0
		end
		
		if fields.include?(:mark)
			_throw(L[:'the field cannot be empty '] + L[:'mark']) if @f[:mark].strip.size < 1
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:content)
			_throw(L[:'the field cannot be empty '] + L[:'content']) if @f[:content].strip.size < 1
		end
		
		if fields.include?(:created)
			_throw(L[:'the field cannot be empty '] + L[:'created']) if @f[:created].strip.size < 1
		end
		
	end

end
