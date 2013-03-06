#display
get '/admin/_sess' do

	ds = DB[:_sess]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:ticket => 'ticket', :uid => 'uid', :changed => 'changed', }
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
 	@_sess = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_sess.page_count

	_tpl :admin__sess

end

#new a record
get '/admin/_sess/new' do

	@title = 'Create a new sessison'
	@rightbar << :save
	_sess_set_fields
	_tpl :admin__sess_form

end

post '/admin/_sess/new' do

	_sess_set_fields
	_sess_valid_fields
	@fields[:changed] = Time.now
	
	DB[:_sess].insert(@fields)
	redirect "/admin/_sess"

end

#delete the record
get '/admin/_sess/rm/:ticket' do

	@title = 'Delete the _sess by id ticket, are you sure ?'
	DB[:_sess].filter(:ticket => params[:ticket].to_i).delete
	redirect "/admin/_sess"

end

#edit the record
get '/admin/_sess/edit/:ticket' do

	@title = 'Edit the sessison'
	@rightbar << :save
	@fields = DB[:_sess].filter(:ticket => params[:ticket]).all[0]
 	_sess_set_fields
 	_tpl :admin__sess_form

end

post '/admin/_sess/edit/:ticket' do

	_sess_set_fields
	_sess_valid_fields
	@fields[:changed] = Time.now
	
	DB[:_sess].filter(:ticket => params[:ticket]).update(@fields)
	redirect "/admin/_sess"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _sess_set_fields
		
		default_values = {
			:ticket		=> '',
			:uid		=> 1
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _sess_valid_fields
		
		_throw "The ticket field cannot be empty." if @fields[:ticket].strip.size < 1
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
	end

end
