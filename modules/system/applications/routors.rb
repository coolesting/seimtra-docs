get '/3s' do
	redirect '/system/info'
end

get '/system/' do
  	slim :system_info
end

get '/system/module' do
	slim :system_module
end

get '/system/errors/:msg' do
	@error_msg = params[:msg]
	slim :system_errors
end
