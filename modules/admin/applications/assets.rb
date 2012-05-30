get '/css/:file_name' do
	static_file params[:file_name], 'css'
end

get '/images/:file_name' do
	static_file params[:file_name], 'images'
end

get '/js/:file_name' do
	static_file params[:file_name], 'js'
end
