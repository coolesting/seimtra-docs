#display
get '/admin/message' do

	@rightbar += [:new, :search]
	ds = DB[:message]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:mid => 'mid', :from_uid => 'from_uid', :to_uid => 'to_uid', :tid => 'tag', :content => 'content', :mark => 'mark', }
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
 	@message = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @message.page_count

	sys_tpl :admin_message

end

#new a record
get '/admin/message/new' do

	@title = 'Create a new message'
	@rightbar << :save
	message_set_fields
	sys_tpl :admin_message_form

end

post '/admin/message/new' do

	message_set_fields
	message_valid_fields
	@fields[:created] = Time.now
	DB[:message].insert(@fields)
	redirect "/admin/message"

end

#delete the record
get '/admin/message/rm/:mid' do

	@title = 'Delete the message by id mid, are you sure ?'
	DB[:message].filter(:mid => params[:mid].to_i).delete
	redirect "/admin/message"

end

#edit the record
get '/admin/message/edit/:mid' do

	@title = 'Edit the message'
	@rightbar << :save
	@fields = DB[:message].filter(:mid => params[:mid]).all[0]
 	message_set_fields
 	sys_tpl :admin_message_form

end

post '/admin/message/edit/:mid' do

	message_set_fields
	message_valid_fields
	DB[:message].filter(:mid => params[:mid]).update(@fields)
	redirect "/admin/message"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def message_set_fields
		
		default_values = {
			:from_uid	=> user_info[:uid],
			:to_uid		=> 1,
			:tid		=> 1,
			:content	=> '',
			:mark		=> 0
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def message_valid_fields
		
		sys_throw "The from_uid field cannot be empty." if @fields[:from_uid] != 0
		
		sys_throw "The to_uid field cannot be empty." if @fields[:to_uid] != 0
		
		field = sys_kv :tag, :tid, :name
		sys_throw "The tid field isn't existing." unless field.include? @fields[:tid].to_i

		sys_throw "The content field cannot be empty." if @fields[:content].strip.size < 1
		
		#sys_throw "The mark field cannot be empty." if @fields[:mark] != 0
		
	end

end
