get '/a' do
	redirect '/admin/'
end

get '/admin/' do
  	slim :admin_info
end

get '/admin/module' do
	slim :admin_module
end

get '/admin/errors/:msg' do
	@error_msg = params[:msg]
	slim :admin_errors
end
