get '/admin/_user' do
	@search = _user_data.keys
	@rightbar << :search
	_user_view
end

get '/admin/_user/rm' do
	_user_rm
end

get '/admin/_user/form' do
	_user_form
end

post '/admin/_user/form' do
	_user_submit
	redirect "/admin/_user"
end

helpers do

	#get the form
	def _user_form fields = [], tpl = :_user_form
		@t[:title] 	= L[:'edit the '] + L[:'_user']
		id 			= @qs.include?(:uid) ? @qs[:uid].to_i : 0
		if id == 0
			data = _user_data
		else
			data = DB[:_user].filter(:uid => id).first 
		end
		_set_fields fields, data
		@f[:pawd] = ''
		_tpl tpl
	end

	#get the view
	def _user_view tpl = :_user_admin

		ds = DB[:_user]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:uid)
		end

		Sequel.extension :pagination
		@_user = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_user.page_count

		_tpl tpl
	end

	#submit the data
	def _user_submit fields = []
		id 	= @qs.include?(:uid) ? @qs[:uid].to_i : 0
		if id == 0
			data = _user_data
			_set_fields fields, data, true
		else
			data = DB[:_user].filter(:uid => id).first 
			_set_fields fields, data
		end
		_user_valid_fields fields

		#insert
		if id == 0
			_user_add @f
		#update
		else
			_user_edit @f
			#DB[:_user].filter(:uid => id).update(@f)
		end
	end

	#remove the record
	def _user_rm id = 0
		if id == 0 and @qs.include?(:uid)
			id = @qs[:uid].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			_user_delete id
		end
		redirect back
	end

	#data construct
	def _user_data
		{
			:name		=> '',
			:pawd		=> '',
			:salt		=> '',
			:level		=> 1,
		}
	end

	def _user_valid_fields fields = []
		_throw L[:'the username need to bigger than two size'] if @f[:name].strip.size < 2
		_throw L[:'the password need to bigger than two size'] if @f[:pawd].strip.size < 2
	end

end
