post '/_upload' do
	
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		_file_save params[:upload]
		'receive the file yet'
	else
		'receive failure'
	end

end

get '/_folder' do

	ds = DB[:_file].filter(:uid => _user[:uid])

	unless ds.empty?
		require 'json'
		JSON.pretty_generate ds.select(:fid, :name, :filetype).reverse_order(:fid).limit(9).all
	else
		nil
	end

end

get '/_file/:fid' do
	ds = DB[:_file].filter(:fid => params[:fid].split('.').first)
	send_file settings.upload_path + ds.get(:path), :type => ds.get(:filetype).to_sym
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
		filetype			= file[:filename].split('.').last
		fields[:filetype]	= filetype if _vars(:filetype).include? filetype

		table = file[:table] ? file[:table].to_sym : :_file
		DB[table].insert(fields)

		file_content = file[:tempfile].read
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
