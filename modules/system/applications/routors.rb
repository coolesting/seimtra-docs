get '/3s' do
	redirect '/system/seimtra'
end

get '/system/seimtra' do
  	slim :system_seimtra
end

get '/system/module' do
	slim :system_module
end

get '/system/setting' do
	@settings = DB[:setting]
	slim :system_setting
end

get '/system/errors/:msg' do
	@error_msg = params[:msg]
	slim :system_errors
end
