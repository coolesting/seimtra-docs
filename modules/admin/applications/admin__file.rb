#display
get '/admin/_file' do

	@rightbar += [:new, :search]
	ds = DB[:_file]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:fid => 'fid', :uid => 'uid', :filetype => 'filetype', :name => 'name', :path => 'path', :created => 'created', }
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
 	@_file = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_file.page_count

	_tpl :admin__file

end

#new a record
get '/admin/_file/new' do

	@title = 'Create a new file'
	@rightbar << :save
	_file_set_fields
	_tpl :admin__file_form

end

post '/admin/_file/new' do

	_file_set_fields
	_file_valid_fields
	@fields[:created] = Time.now
	
	
	DB[:_file].insert(@fields)
	redirect "/admin/_file"

end

#delete the record
get '/admin/_file/rm/:fid' do

	_msg 'Delete the _file by id fid.'
	DB[:_file].filter(:fid => params[:fid].to_i).delete
	redirect "/admin/_file"

end

#edit the record
get '/admin/_file/edit/:fid' do

	@title = 'Edit the file'
	@rightbar << :save
	@fields = DB[:_file].filter(:fid => params[:fid]).all[0]
 	_file_set_fields
 	_tpl :admin__file_form

end

post '/admin/_file/edit/:fid' do

	_file_set_fields
	_file_valid_fields
	
	
	DB[:_file].filter(:fid => params[:fid]).update(@fields)
	redirect "/admin/_file"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _file_set_fields
		
		default_values = {
			:uid		=> 1,
			:filetype		=> '',
			:name		=> '',
			:path		=> '',
			:created		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _file_valid_fields
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		_throw "The filetype field cannot be empty." if @fields[:filetype].strip.size < 1
		
		_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
		_throw "The path field cannot be empty." if @fields[:path].strip.size < 1
		
		_throw "The created field cannot be empty." if @fields[:created].strip.size < 1
		
	end

end
