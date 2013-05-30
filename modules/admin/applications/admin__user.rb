#display
get '/admin/_user' do

	@rightbar += [:new, :search]
	ds = DB[:_user]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:uid => 'uid', :name => 'name', :pawd => 'pawd', :level => 'level', :salt => 'salt', :created => 'created', }
	end

	#order
	if @qs[:order]
		if @qs.has_key? :desc
			ds = ds.reverse_order(@qs[:order].to_sym)
			@qs.delete :desc
		else
			ds = ds.order(@qs[:order].to_sym)
			@qs[:desc] = 'yes'
		end
	end

	Sequel.extension :pagination
 	@_user = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_user.page_count

	_tpl :admin__user

end

#new a record
get '/admin/_user/new' do

	@title = 'Create a new user'
	@rightbar << :save
	_user_set_fields
	_tpl :admin__user_form

end

post '/admin/_user/new' do

	_user_valid params[:name], params[:pawd]
	_user_add params[:name], params[:pawd]
	redirect "/admin/_user"

end

#delete the record
get '/admin/_user/rm/:uid' do

	@title = 'Delete the _user by id uid, are you sure ?'
	_user_delete params[:uid]
	redirect "/admin/_user"

end

#edit the record
get '/admin/_user/edit/:uid' do

	@title = 'Edit the user'
	@rightbar << :save
	@fields = DB[:_user].filter(:uid => params[:uid]).all[0]
 	_user_set_fields
	@fields[:pawd] = ''
 	_tpl :admin__user_form

end

post '/admin/_user/edit/:uid' do
	_user_edit params
	redirect "/admin/_user"
end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _user_set_fields
		
		default_values = {
			:name		=> '',
			:pawd		=> '',
			:level		=> 1,
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

end
