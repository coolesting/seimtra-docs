#display
get '/system/tag' do

	sys_opt :new, :search
	ds = DB[:tag]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if settings.sys_opt.include? :search
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
 	@tag = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @tag.page_count

	slim :system_tag

end

#new a record
get '/system/tag/new' do

	@title = 'Create a new tag'
	sys_opt :save
	tag_set_fields
	slim :system_tag_form

end

post '/system/tag/new' do

	tag_set_fields
	tag_valid_fields
	DB[:tag].insert(@fields)
	redirect "/system/tag"

end

#delete the record
get '/system/tag/rm/:tid' do

	@title = 'Delete the tag by id tid, are you sure ?'
	DB[:tag].filter(:tid => params[:tid].to_i).delete
	redirect "/system/tag"

end

#edit the record
get '/system/tag/edit/:tid' do

	@title = 'Edit the tag'
	sys_opt :save
	@fields = DB[:tag].filter(:tid => params[:tid]).all[0]
 	tag_set_fields
 	slim :system_tag_form

end

post '/system/tag/edit/:tid' do

	tag_set_fields
	tag_valid_fields
	DB[:tag].filter(:tid => params[:tid].to_i).update(@fields)
	redirect "/system/tag"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def tag_set_fields
		
		default_values = {
			:name		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def tag_valid_fields
		
		throw_error "The name field cannot be empty." if @fields[:name] == ""
		
	end
	
end
