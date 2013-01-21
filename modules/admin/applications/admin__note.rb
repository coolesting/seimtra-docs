#display
get '/admin/_note' do

	@rightbar += [:new, :search]
	ds = DB[:_note]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
		@search = {:nid => 'nid', :from_uid => 'from_uid', :to_uid => 'to_uid', :mark => 'mark', :tid => 'tid', :content => 'content', :created => 'created', }
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
 	@_note = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @_note.page_count

	_tpl :admin__note

end

#new a record
get '/admin/_note/new' do

	@title = 'Create a new note'
	@rightbar << :save
	_note_set_fields
	_tpl :admin__note_form

end

post '/admin/_note/new' do

	_note_set_fields
	_note_valid_fields
	@fields[:created] = Time.now
	DB[:_note].insert(@fields)
	redirect "/admin/_note"

end

#delete the record
get '/admin/_note/rm/:nid' do

	_msg 'Delete the _note by id nid.'
	DB[:_note].filter(:nid => params[:nid].to_i).delete
	redirect "/admin/_note"

end

#edit the record
get '/admin/_note/edit/:nid' do

	@title = 'Edit the note'
	@rightbar << :save
	@fields = DB[:_note].filter(:nid => params[:nid]).all[0]
 	_note_set_fields
 	_tpl :admin__note_form

end

post '/admin/_note/edit/:nid' do

	_note_set_fields
	_note_valid_fields
	DB[:_note].filter(:nid => params[:nid]).update(@fields)
	redirect "/admin/_note"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def _note_set_fields
		
		default_values = {
			:from_uid		=> 1,
			:to_uid		=> 1,
			:mark		=> 1,
			:tid		=> 1,
			:content	=> '',
			:created	=> ''
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def _note_valid_fields
		
		#_throw "The from_uid field cannot be empty." if @fields[:from_uid] != 0
		
		#_throw "The to_uid field cannot be empty." if @fields[:to_uid] != 0
		
		#_throw "The mark field cannot be empty." if @fields[:mark] != 0
		
		#_throw "The tid field cannot be empty." if @fields[:tid] != 0
		
		_throw "The content field cannot be empty." if @fields[:content].strip.size < 1
		
		_throw "The created field cannot be empty." if @fields[:created].strip.size < 1
		
	end

end
