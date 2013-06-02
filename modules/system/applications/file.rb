before '/_file/*' do
	#set the level
	if request.path == '/_file/upload'
		_level _var(:upload_level, :file)
	end
end

#upload file
post '/_file/upload' do
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		L[:'upload complete']
	else
		L[:'the file is null']
	end
end

#get file list by type
get '/_file/type/:type' do
	ds = DB[:_file].filter(:uid => _user[:uid])
	unless ds.empty?
		require 'json'
		if params[:type] == 'all'
			result = ds.select(:fid, :name, :type).reverse_order(:fid).limit(9).all
		elsif params[:type] == 'picture'
			result = ds.select(:fid, :name, :type).reverse_order(:fid).limit(9).all
		end
		JSON.pretty_generate result
	else
		nil
	end
end

#get the file by id
get '/_file/get/:fid' do
	ds = DB[:_file].filter(:fid => params[:fid].split('.').first)
	send_file settings.upload_path + ds.get(:path), :type => ds.get(:type).split('/').last.to_sym
end

helpers do
	
	#save file info to db
	#== required fields
	#	:filename, tempfile
	#== options
	#	:table, store the file info
	def _file_save file
		fields = {}
		fields[:uid] 		= _user[:uid]
		fields[:name] 		= file[:filename].split('.').first
		fields[:created]	= Time.now
		fields[:type]		= file[:type]
		fields[:path] 		= "/#{_user[:uid]}-#{fields[:created].to_i}"

		#validate
		unless _var(:filetype, :file).include? file[:type]
			_throw L[:'the file type is wrong']
		end
		file_content = file[:tempfile].read
		if (fields[:size] = file_content.size) > _var(:filesize, :file).to_i
			_throw L[:'the file size is too big']
		end

		#save the info of file
		table = file[:table] ? file[:table].to_sym : :_file
		DB[table].insert(fields)

		#save the body of file
		File.open(settings.upload_path + fields[:path], 'w+') do | f |
			f.write file_content
		end
	end

	def _parser_init extension = {}
		require 'redcarpet'
		extensions = {:autolink => true, :space_after_headers => true}
		extensions.merge! extension
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions)
	end

	def _m2h str
		@markdown.render str
	end
end
