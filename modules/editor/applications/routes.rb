
get '/admin/editor' do
	sys_tpl :default
end

post '/upload' do
	
	if params[:upload] and params[:upload][:tempfile] and params[:upload][:filename]
		file_content = params[:upload][:tempfile].read
		File.open(settings.upload_path + '/' + Time.now.strftime("%s") + "-#{params[:upload][:filename]}", 'w+') do | file |
			file.write file_content
		end
		'receive the file yet'
	else
		'receive failure'
	end

end

get '/upload' do
	slim :editor_upload
end

helpers do
	def editor_init_parser
		require 'redcarpet'
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
	end

	def editor_m2h str
		@markdown.render str
	end
end
