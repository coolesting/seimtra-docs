#display
get '/system/tag' do

	sys_opt :new
	ds = DB[:tag]

	Sequel.extension :pagination
 	@tag = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @tag.page_count

	slim :system_tag

end

#new a record
get '/system/tag/new' do

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

	DB[:tag].filter(:tid => params[:tid].to_i).delete
	redirect "/system/tag"

end

#edit the record
get '/system/tag/edit/:tid' do

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
