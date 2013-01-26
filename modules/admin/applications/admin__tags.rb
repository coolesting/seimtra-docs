#display
get '/admin/_tags' do

	@rightbar += [:new, :search]
	ds = DB[:_tags]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:tid => 'tid', :name => 'name', }
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
 	@_tags = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_tags.page_count

	_tpl :admin__tags

end

#new a record
get '/admin/_tags/new' do

	@title = 'Create a new _tags'
	@rightbar << :save
	_tags_set_fields
	_tpl :admin__tags_form

end

post '/admin/_tags/new' do

	_tags_set_fields
	_tags_valid_fields
	DB[:_tags].insert(@fields)
	redirect "/admin/_tags"

end

#delete the record
get '/admin/_tags/rm/:tid' do

	_msg 'Delete the _tags by id tid.'
	DB[:_tags].filter(:tid => params[:tid].to_i).delete
	redirect "/admin/_tags"

end

#edit the record
get '/admin/_tags/edit/:tid' do

	@title = 'Edit the _tags'
	@rightbar << :save
	@fields = DB[:_tags].filter(:tid => params[:tid]).all[0]
 	_tags_set_fields
 	_tpl :admin__tags_form

end

post '/admin/_tags/edit/:tid' do

	_tags_set_fields
	_tags_valid_fields
	DB[:_tags].filter(:tid => params[:tid]).update(@fields)
	redirect "/admin/_tags"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _tags_set_fields
		
		default_values = {
			:name		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _tags_valid_fields
		
		_throw "The name field cannot be empty." if @fields[:name].strip.size < 1
		
	end

end
