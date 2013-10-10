get '/admin/_file' do
	@search = _file_data.keys
	@rightbar << :search
	_file_view
end

get '/admin/_file/rm' do
	_file_rm
end

get '/admin/_file/form' do
	_file_form
end

post '/admin/_file/form' do
	_file_submit
	redirect "/admin/_file"
end

module Helpers

	#get the form
	def _file_form fields = [], tpl = :_file_form
		@t[:title] 	= L[:'edit the '] + L[:'_file']
		id 			= @qs.include?(:fid) ? @qs[:fid].to_i : 0
		if id == 0
			data = _file_data
		else
			data = DB[:_file].filter(:fid => id).first 
		end
		_set_fields fields, data
		_tpl tpl
	end

	#get the view
	def _file_view tpl = :_file_admin

		ds = DB[:_file]

		#search content
		ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(:fid)
		end

		Sequel.extension :pagination
		@_file = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @_file.page_count

		_tpl tpl
	end

	#submit the data
	def _file_submit
		if params[:upload]
			params[:upload].each do | p |
				_file_save p
			end
			_msg L[:'upload complete']
		else
			_msg L[:'the file is null']
		end
	end

	#data construct
	def _file_data
		{
			:uid		=> _user[:uid],
			:size		=> 1,
			:type		=> '',
			:name		=> '',
			:path		=> '',
		}
	end

	def _file_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
		if fields.include?(:size)
			#_throw(L[:'the field cannot be empty '] + L[:'size']) if @f[:size] != 0
		end
		
		if fields.include?(:type)
			_throw(L[:'the field cannot be empty '] + L[:'type']) if @f[:type].strip.size < 1
		end
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
		if fields.include?(:path)
			_throw(L[:'the field cannot be empty '] + L[:'path']) if @f[:path].strip.size < 1
		end
		
		if fields.include?(:created)
			_throw(L[:'the field cannot be empty '] + L[:'created']) if @f[:created].strip.size < 1
		end
		
	end

end
