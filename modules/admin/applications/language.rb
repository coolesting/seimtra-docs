#display
get '/admin/language' do

	@rightbar += [:new, :search]
	ds = DB[:language]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:label => 'label', :content => 'content', :mid => 'name', }
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
 	@language = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @language.page_count

	sys_tpl :admin_language

end

#new a record
get '/admin/language/new' do

	@title = 'Create a new language'
	@rightbar << :save
	language_set_fields
	sys_tpl :admin_language_form

end

post '/admin/language/new' do

	language_set_fields
	language_valid_fields
	DB[:language].insert(@fields)
	redirect "/admin/language"

end

#delete the record
get '/admin/language/rm/:label' do

	@title = 'Delete the language by id label, are you sure ?'
	DB[:language].filter(:label => params[:label].to_i).delete
	redirect "/admin/language"

end

#edit the record
get '/admin/language/edit/:label' do

	@title = 'Edit the language'
	@rightbar << :save
	@fields = DB[:language].filter(:label => params[:label]).all[0]
 	language_set_fields
 	sys_tpl :admin_language_form

end

post '/admin/language/edit/:label' do

	language_set_fields
	language_valid_fields
	DB[:language].filter(:label => params[:label]).update(@fields)
	redirect "/admin/language"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def language_set_fields
		
		default_values = {
			:label		=> '',
			:content		=> '',
			:mid		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def language_valid_fields
		
		sys_throw "The label field cannot be empty." if @fields[:label].strip.size < 1
		
		sys_throw "The content field cannot be empty." if @fields[:content].strip.size < 1
		
		field = sys_kv :module, :mid, :name
		sys_throw "The mid field isn't existing." unless field.include? @fields[:mid].to_i
		
	end

end
