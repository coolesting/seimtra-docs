get '/admin/_menu' do
	@search = _menu_data.keys
	@rightbar << :search
	_menu_view
end

get '/admin/_menu/rm' do
	_menu_rm
end

get '/admin/_menu/form' do
	_menu_form
end

post '/admin/_menu/form' do
	_menu_submit
	redirect "/admin/_menu"
end

helpers do

	#get the form
	def _menu_form fields = [], tpl = :_menu_form
		@t[:title] 	= L[:'edit the '] + L[:'_menu']
		id 			= @qs.include?(:mid) ? @qs[:mid].to_i : 0
		if id == 0
			data = _menu_data
		else
			data = DB[:_menu].filter(:mid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _menu_view tpl = :_menu_admin

		ds = DB[:_menu]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:mid)
		end

		Sequel.extension :pagination
		@_menu = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_menu.page_count

		_tpl tpl
	end

	#submit the data
	def _menu_submit fields = []
		id 	= @qs.include?(:mid) ? @qs[:mid].to_i : 0
		if id == 0
			data = _menu_data
			_set_fields fields, data, true
		else
			data = DB[:_menu].filter(:mid => id).first 
			_set_fields fields, data
		end
		_menu_valid_fields fields

		#insert
		if id == 0
			DB[:_menu].insert(@f)
		#update
		else
			DB[:_menu].filter(:mid => id).update(@f)
		end
	end

	#remove the record
	def _menu_rm id = 0
		if id == 0 and @qs.include?(:mid)
			id = @qs[:mid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:_menu].filter(:mid => id).delete
		end
		redirect back
	end

	#data construct
	def _menu_data
		{
			:tid		=> 1,
			:uid		=> _user[:uid],
			:preid		=> 0,
			:order		=> 9,
			:name		=> '',
			:link		=> '',
			:description		=> '',
		}
	end

	def _menu_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:preid)
			#_throw(L[:'the field cannot be empty '] + L[:'preid']) if @f[:preid] != 0
		end
		
		if fields.include?(:order)
			#_throw(L[:'the field cannot be empty '] + L[:'order']) if @f[:order] != 0
		end
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
		if fields.include?(:link)
			_throw(L[:'the field cannot be empty '] + L[:'link']) if @f[:link].strip.size < 1
		end
		
		if fields.include?(:description)
			_throw(L[:'the field cannot be empty '] + L[:'description']) if @f[:description].strip.size < 1
		end
		
	end

end
