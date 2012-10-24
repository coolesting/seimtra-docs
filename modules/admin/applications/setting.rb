#display
get '/admin/setting' do

	sys_opt :new, :search
	ds = DB[:setting]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if settings.sys_opt.include? :search
		@search = {:skey => 'skey', :sval => 'sval', :changed => 'changed', }
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
 	@setting = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @setting.page_count

	slim :admin_setting

end

#new a record
get '/admin/setting/new' do

	@title = 'Create a new setting'
	sys_opt :save
	setting_set_fields
	slim :admin_setting_form

end

post '/admin/setting/new' do

	setting_set_fields
	setting_valid_fields
	DB[:setting].insert(@fields)
	redirect "/admin/setting"

end

#delete the record
get '/admin/setting/rm/:skey' do

	@title = 'Delete the setting by id skey, are you sure ?'
	DB[:setting].filter(:skey => params[:skey].to_i).delete
	redirect "/admin/setting"

end

#edit the record
get '/admin/setting/edit/:skey' do

	@title = 'Edit the setting'
	sys_opt :save
	@fields = DB[:setting].filter(:skey => params[:skey]).all[0]
 	setting_set_fields
 	slim :admin_setting_form

end

post '/admin/setting/edit/:skey' do

	setting_set_fields
	setting_valid_fields
	DB[:setting].filter(:skey => params[:skey]).update(@fields)
	redirect "/admin/setting"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def setting_set_fields
		
		default_values = {
			:skey		=> '',
			:sval		=> '',
			:changed		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def setting_valid_fields
		
		throw_error "The skey field cannot be empty." if @fields[:skey] == ""
		
		throw_error "The sval field cannot be empty." if @fields[:sval] == ""
		
		throw_error "The changed field cannot be empty." if @fields[:changed] == ""
		
	end
	
end
