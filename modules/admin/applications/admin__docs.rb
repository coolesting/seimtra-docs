#display
get '/admin/_docs' do

	@rightbar += [:new, :search]
	ds = DB[:_docs]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:doid => 'doid', :tid => 'tid', :uid => 'uid', :name => 'name', :body => 'body', :created => 'created', }
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
 	@_docs = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_docs.page_count

	_tpl :admin__docs

end

#new a record
get '/admin/_docs/new' do

	@title = L[:'create a new one '] + L['document']
	@rightbar << :save
	_docs_set_fields
	_tpl :admin__docs_form

end

post '/admin/_docs/new' do

	_docs_set_fields
	_docs_valid_fields
	@fields[:created] = Time.now
	DB[:_docs].insert(@fields)
	redirect "/admin/_docs"

end

#delete the record
get '/admin/_docs/rm/:doid' do

	_msg L[:'delete the record by id '] + params[:doid]
	DB[:_docs].filter(:doid => params[:doid].to_i).delete
	redirect "/admin/_docs"

end

#edit the record
get '/admin/_docs/edit/:doid' do

	@title = L[:'edit the '] + L[:'document']
	@rightbar << :save
	@fields = DB[:_docs].filter(:doid => params[:doid]).all[0]
 	_docs_set_fields
 	_tpl :admin__docs_form

end

post '/admin/_docs/edit/:doid' do

	_docs_set_fields
	_docs_valid_fields
	DB[:_docs].filter(:doid => params[:doid]).update(@fields)
	redirect "/admin/_docs"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _docs_set_fields
		
		default_values = {
			:tid		=> 1,
			:uid		=> _user[:uid],
			:name		=> '',
			:body		=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _docs_valid_fields
		
		#_throw "The tid field cannot be empty." if @fields[:tid] != 0
		
		#_throw "The uid field cannot be empty." if @fields[:uid] != 0
		
		_throw(L[:'The field cannot be empty.'] + L[:'name']) if @fields[:name].strip.size < 1
		
		_throw(L[:'The field cannot be empty.'] + L[:'body']) if @fields[:body].strip.size < 1
		 
	end

end
