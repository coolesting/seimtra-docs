#display
get '/admin/user_base' do

	@rightbar += [:new, :search]
	ds = DB[:user_base]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:uid => 'uid', :nickname => 'nickname', :description => 'description', :picture => 'picture', :email => 'email', :changed => 'changed', }
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
 	@user_base = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user_base.page_count

	sys_tpl :admin_user_base

end

#new a record
get '/admin/user_base/new' do

	@title = 'Create a new user_base'
	@rightbar << :save
	user_base_set_fields
	sys_tpl :admin_user_base_form

end

post '/admin/user_base/new' do

	user_base_set_fields
	user_base_valid_fields
	@fields[:changed] = Time.now
	
	DB[:user_base].insert(@fields)
	redirect "/admin/user_base"

end

#delete the record
get '/admin/user_base/rm/:uid' do

	@title = 'Delete the user_base by id uid, are you sure ?'
	DB[:user_base].filter(:uid => params[:uid].to_i).delete
	redirect "/admin/user_base"

end

#edit the record
get '/admin/user_base/edit/:uid' do

	@title = 'Edit the user_base'
	@rightbar << :save
	@fields = DB[:user_base].filter(:uid => params[:uid]).all[0]
 	user_base_set_fields
 	sys_tpl :admin_user_base_form

end

post '/admin/user_base/edit/:uid' do

	user_base_set_fields
	user_base_valid_fields
	@fields[:changed] = Time.now
	
	DB[:user_base].filter(:uid => params[:uid].to_i).update(@fields)
	redirect "/admin/user_base"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def user_base_set_fields
		
		default_values = {
			:uid		=> user_info[:uid],
			:nickname	=> '',
			:description=> '',
			:picture	=> '',
			:email		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def user_base_valid_fields
		
		sys_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		sys_throw "The nickname field cannot be empty." if @fields[:nickname].strip.size < 1
		
		sys_throw "The description field cannot be empty." if @fields[:description].strip.size < 1
		
		sys_throw "The picture field cannot be empty." if @fields[:picture].strip.size < 1
		
		sys_throw "The email field cannot be empty." if @fields[:email].strip.size < 1
		
	end

end
