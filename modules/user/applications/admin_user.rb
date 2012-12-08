get '/admin/user' do

	@title = 'user list.'
	@rightbar << :new
	ds = DB[:user]

	Sequel.extension :pagination
 	@user = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user.page_count

	sys_slim :admin_user

end

# new a record
get '/admin/user/new' do

	@title = 'Create a new user.'
	@rightbar << :save
	sys_slim :admin_user_form

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
	@rightbar << :save
	@fields = DB[:user].filter(:uid => params[:uid]).all[0]
	@fields[:pawd] = ""
 	sys_slim :admin_user_form

end

post '/admin/user/edit/:uid' do

	user_valid params[:name], params[:pawd]
	user_edit params
	redirect "/admin/user"

end
