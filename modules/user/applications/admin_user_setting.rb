#display
get '/admin/user_setting' do

	@rightbar += [:new, :search]
	ds = DB[:user_setting]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:uid => 'uid', :level => 'level', :integral => 'integral', :timeout => 'timeout', :layout => 'layout', :changed => 'changed', }
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
 	@user_setting = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user_setting.page_count

	sys_tpl :admin_user_setting

end

#new a record
get '/admin/user_setting/new' do

	@title = 'Create a new user_setting'
	@rightbar << :save
	user_setting_set_fields
	sys_tpl :admin_user_setting_form

end

post '/admin/user_setting/new' do

	user_setting_set_fields
	user_setting_valid_fields
	@fields[:changed] = Time.now
	
	DB[:user_setting].insert(@fields)
	redirect "/admin/user_setting"

end

#delete the record
get '/admin/user_setting/rm/:uid' do

	@title = 'Delete the user_setting by id uid, are you sure ?'
	DB[:user_setting].filter(:uid => params[:uid].to_i).delete
	redirect "/admin/user_setting"

end

#edit the record
get '/admin/user_setting/edit/:uid' do

	@title = 'Edit the user_setting'
	@rightbar << :save
	@fields = DB[:user_setting].filter(:uid => params[:uid]).all[0]
 	user_setting_set_fields
 	sys_tpl :admin_user_setting_form

end

post '/admin/user_setting/edit/:uid' do

	user_setting_set_fields
	user_setting_valid_fields
	@fields[:changed] = Time.now
	
	DB[:user_setting].filter(:uid => params[:uid].to_i).update(@fields)
	redirect "/admin/user_setting"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def user_setting_set_fields
		
		default_values = {
			:uid		=> user_info[:uid],
			:level		=> 1,
			:integral	=> 50,
			:timeout	=> 30,
			:layout		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def user_setting_valid_fields
		
		sys_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		sys_throw "The level field cannot be empty." if @fields[:level] != 0
		
		sys_throw "The integral field cannot be empty." if @fields[:integral] != 0
		
		sys_throw "The timeout field cannot be empty." if @fields[:timeout] != 0
		
		sys_throw "The layout field cannot be empty." if @fields[:layout].strip.size < 1
		
	end

end
