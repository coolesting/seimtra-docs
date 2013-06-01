#display
get '/admin/_file' do

	@rightbar += [:new, :search]
	ds = DB[:_file]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:fid => 'fid', :uid => 'uid', :size => 'size', :type => 'type', :name => 'name', :path => 'path', :created => 'created', }
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
	@title = L[:'create a new one '] + L['file']
	@rightbar << :save
	_file_set_fields
	_tpl :admin__file_form
end

post '/admin/_file/new' do
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		_msg L[:'upload complete']
	else
		_msg L[:'the file is null']
	end
	redirect "/admin/_file"
end

#delete the record
get '/admin/_file/rm/:fid' do
	_msg L[:'delete the record by id '] + params[:fid]
	DB[:_file].filter(:fid => params[:fid].to_i).delete
	redirect "/admin/_file"
end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _file_set_fields
		
		default_values = {
			:uid		=> _user[:uid],
			:type		=> '',
			:size		=> '',
			:name		=> '',
			:path		=> '',
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _file_valid_fields
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		_throw(L[:'The field cannot be empty.'] + L[:'filetype']) if @fields[:type].strip.size < 1
		
		_throw(L[:'The field cannot be empty.'] + L[:'filename']) if @fields[:name].strip.size < 1
		
		_throw(L[:'The field cannot be empty.'] + L[:'path']) if @fields[:path].strip.size < 1
		
	end

end
