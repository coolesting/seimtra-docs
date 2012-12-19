#display
get '/admin/user_ticket' do

	@rightbar += [:new, :search]
	ds = DB[:user_ticket]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:name => 'name', :uid => 'uid', :location => 'location', :ip => 'ip', :created => 'created', }
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
 	@user_ticket = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @user_ticket.page_count

	sys_tpl :admin_user_ticket

end

#new a record
get '/admin/user_ticket/new' do

	@title = 'Create a new user_ticket'
	@rightbar << :save
	user_ticket_set_fields
	sys_tpl :admin_user_ticket_form

end

post '/admin/user_ticket/new' do

	user_ticket_set_fields
	user_ticket_valid_fields
	
	
	DB[:user_ticket].insert(@fields)
	redirect "/admin/user_ticket"

end

#delete the record
get '/admin/user_ticket/rm/:name' do

	@title = 'Delete the user_ticket by id name, are you sure ?'
	DB[:user_ticket].filter(:name => params[:name].to_i).delete
	redirect "/admin/user_ticket"

end

#edit the record
get '/admin/user_ticket/edit/:name' do

	@title = 'Edit the user_ticket'
	@rightbar << :save
	@fields = DB[:user_ticket].filter(:name => params[:name]).all[0]
 	user_ticket_set_fields
 	sys_tpl :admin_user_ticket_form

end

post '/admin/user_ticket/edit/:name' do

	user_ticket_set_fields
	user_ticket_valid_fields
	
	
	DB[:user_ticket].filter(:name => params[:name]).update(@fields)
	redirect "/admin/user_ticket"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def user_ticket_set_fields
		
		default_values = {
			:name		=> '',
			:uid		=> 1,
			:location		=> '',
			:ip		=> '',
			:created		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def user_ticket_valid_fields
		
		sys_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		sys_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		sys_throw "The location field cannot be empty." if @fields[:location].strip.size < 1
		
		sys_throw "The ip field cannot be empty." if @fields[:ip].strip.size < 1
		
		sys_throw "The created field cannot be empty." if @fields[:created].strip.size < 1
		
	end

end
