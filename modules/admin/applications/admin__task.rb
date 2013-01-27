#display
get '/admin/_task' do

	@rightbar += [:new, :search]
	ds = DB[:_task]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:taid => 'taid', :tid => 'tag', :uid => 'uid', :method_name => 'method_name', :timeout => 'timeout', :changed => 'changed', }
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
 	@_task = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_task.page_count

	_tpl :admin__task

end

#new a record
get '/admin/_task/new' do

	@title = 'Create a new task'
	@rightbar << :save
	_task_set_fields
	_tpl :admin__task_form

end

post '/admin/_task/new' do

	_task_set_fields
	_task_valid_fields
	@fields[:changed] = Time.now
	
	DB[:_task].insert(@fields)
	redirect "/admin/_task"

end

#delete the record
get '/admin/_task/rm/:taid' do

	@title = 'Delete the _task by id taid, are you sure ?'
	DB[:_task].filter(:taid => params[:taid].to_i).delete
	redirect "/admin/_task"

end

#edit the record
get '/admin/_task/edit/:taid' do

	@title = 'Edit the task'
	@rightbar << :save
	@fields = DB[:_task].filter(:taid => params[:taid]).all[0]
 	_task_set_fields
 	_tpl :admin__task_form

end

post '/admin/_task/edit/:taid' do

	_task_set_fields
	_task_valid_fields
	@fields[:changed] = Time.now
	
	DB[:_task].filter(:taid => params[:taid]).update(@fields)
	redirect "/admin/_task"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _task_set_fields
		
		default_values = {
			:uid			=> 1,
			:method_name	=> '',
			:tid			=> 1,
			:timeout		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _task_valid_fields
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0

		_throw "The method name field cannot be empty." if @fields[:method_name].strip.size < 1
		
		#_throw "The timeout field cannot be empty." if @fields[:timeout] != 0
		
	end

end
