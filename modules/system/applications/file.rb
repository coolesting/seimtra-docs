before '/_file/*' do
	#set the level
	if reqest.path == '/_file/upload'
		_level _vars(:uploadfile)
	end
end

#upload file
post '/_file/upload' do
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		'upload complete.'
	else
		'the file is null'
	end
end

#get the specify file
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

#get the file by file id
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
		fields[:path] 		= "/#{_user[:uid]}-" + fields[:created].strftime("%s") + "-#{file[:filename]}"
		fields[:type]		= file[:type]

		unless _vars(:filetype).include? file[:type]
			_throw 'the file type is wrong.'
		end

		file_content = file[:tempfile].read
		if (fields[:size] = file_content.size) > _vars(:filesize).to_i
			_throw 'the file size is too big.'
		end

		#insert db
		table = file[:table] ? file[:table].to_sym : :_file
		DB[table].insert(fields)

		#move the file
		File.open(settings.upload_path + fields[:path], 'w+') do | f |
			f.write file_content
		end
	end

	def _parser_init
		require 'redcarpet'
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
	end

	def _m2h str
		@markdown.render str
	end
end
