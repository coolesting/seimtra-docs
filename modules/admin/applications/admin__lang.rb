#display
get '/admin/_lang' do

	@rightbar += [:new, :search]
	ds = DB[:_lang]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:lid => 'lid', :label => 'label', :content => 'content', :uid => 'uid', }
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
 	@_lang = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_lang.page_count

	_tpl :admin__lang

end

#new a record
get '/admin/_lang/new' do

	@title = L[:'create a new one '] + L['language']
	@rightbar << :save
	_lang_set_fields
	_tpl :admin__lang_form

end

post '/admin/_lang/new' do

	_lang_set_fields
	_lang_valid_fields
	
	
	DB[:_lang].insert(@fields)
	redirect "/admin/_lang"

end

#delete the record
get '/admin/_lang/rm/:lid' do

	_msg L[:'delete the record by id '] + params[:lid]
	DB[:_lang].filter(:lid => params[:lid].to_i).delete
	redirect "/admin/_lang"

end

#edit the record
get '/admin/_lang/edit/:lid' do

	@title = L[:'edit the '] + L[:'language']
	@rightbar << :save
	@fields = DB[:_lang].filter(:lid => params[:lid]).all[0]
 	_lang_set_fields
 	_tpl :admin__lang_form

end

post '/admin/_lang/edit/:lid' do

	_lang_set_fields
	_lang_valid_fields
	
	
	DB[:_lang].filter(:lid => params[:lid]).update(@fields)
	redirect "/admin/_lang"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _lang_set_fields
		
		default_values = {
			:label		=> '',
			:content	=> '',
			:uid		=> _user[:uid]
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _lang_valid_fields
		
		_throw "The label field cannot be empty." if @fields[:label].strip.size < 1
		
		_throw "The content field cannot be empty." if @fields[:content].strip.size < 1
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
	end

end
