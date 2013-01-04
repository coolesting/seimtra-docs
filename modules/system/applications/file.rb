post '/_upload' do
	
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		'receive the file yet'
	else
		'receive failure'
	end

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
		fields[:name] 		= file[:filename]
		fields[:created]	= Time.now
		fields[:path] 		= settings.upload_path + "/#{user[:uid]}-" + fields[:created].strftime("%s") + "-#{file[:filename]}"
		filetype			= file[:filename].split('.').last
		fields[:filetype]	= filetype if _vars(:filetype).include? filetype.to_sym

		table = file[:table] ? file[:table].to_sym : :_file
		DB[table].insert(fields)

		file_content = file[:tempfile].read
		File.open(fields[:path], 'w+') do | f |
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
