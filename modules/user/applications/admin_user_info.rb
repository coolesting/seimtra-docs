#display
get '/admin/user_info' do

	@rightbar += [:new, :search]
	ds = DB[:user_info]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:uid => 'uid', :level => 'level', :integral => 'integral', :timeout => 'timeout', :nickname => 'nickname', :email => 'email', :picture => 'picture', :changed => 'changed', :resume => 'resume', }
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
 	@user_info = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user_info.page_count

	sys_tpl :admin_user_info

end

#new a record
get '/admin/user_info/new' do

	@title = 'Create a new user_info'
	@rightbar << :save
	user_info_set_fields
	sys_tpl :admin_user_info_form

end

post '/admin/user_info/new' do

	user_info_set_fields
	user_info_valid_fields
	
	@fields[:changed] = Time.now
	
	DB[:user_info].insert(@fields)
	redirect "/admin/user_info"

end

#delete the record
get '/admin/user_info/rm/:uid' do

	@title = 'Delete the user_info by id uid, are you sure ?'
	DB[:user_info].filter(:uid => params[:uid].to_i).delete
	redirect "/admin/user_info"

end

#edit the record
get '/admin/user_info/edit/:uid' do

	@title = 'Edit the user_info'
	@rightbar << :save
	@fields = DB[:user_info].filter(:uid => params[:uid]).all[0]
 	user_info_set_fields
 	sys_tpl :admin_user_info_form

end

post '/admin/user_info/edit/:uid' do

	user_info_set_fields
	user_info_valid_fields
	@fields[:changed] = Time.now
	
	DB[:user_info].filter(:uid => params[:uid].to_i).update(@fields)
	redirect "/admin/user_info"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def user_info_set_fields
		
		default_values = {
			:uid		=> 1,
			:level		=> 1,
			:integral	=> 50,
			:timeout	=> 30,
			:nickname	=> '',
			:email		=> '',
			:picture	=> '',
			:resume		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def user_info_valid_fields
		
		sys_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		sys_throw "The level field cannot be empty." if @fields[:level] != 0
		
		sys_throw "The integral field cannot be empty." if @fields[:integral] != 0
		
		sys_throw "The timeout field cannot be empty." if @fields[:timeout] != 0
		
		sys_throw "The nickname field cannot be empty." if @fields[:nickname].strip.size < 1
		
		sys_throw "The email field cannot be empty." if @fields[:email].strip.size < 1
		
		sys_throw "The picture field cannot be empty." if @fields[:picture].strip.size < 1
		
		sys_throw "The resume field cannot be empty." if @fields[:resume].strip.size < 1
		
	end

end
