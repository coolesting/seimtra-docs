get '/admin/user' do

	@title = 'user list.'
	sys_opt :new
	ds = DB[:user]

	Sequel.extension :pagination
 	@user = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user.page_count

	slim :admin_user

end

# new a record
get '/admin/user/new' do

	@title = 'Create a new user.'
	sys_opt :save
	slim :admin_user_form

end

post '/admin/user/new' do

	user_valid params[:name], params[:pawd]
	user_add params[:name], params[:pawd]
	redirect "/admin/user"

end

#delete the record
get '/admin/user/rm/:uid' do

	user_delete params[:uid]
	redirect "/admin/user"

end

# edit the record
get '/admin/user/edit/:uid' do

	@title = 'Edit the user.'
	sys_opt :save
	@fields = DB[:user].filter(:uid => params[:uid]).all[0]
	@fields[:pawd] = ""
 	slim :admin_user_form

end

post '/admin/user/edit/:uid' do

	user_valid params[:name], params[:pawd]
	user_edit params
	redirect "/admin/user"

end
