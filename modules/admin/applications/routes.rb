get '/a' do
	redirect '/admin/'
end

get '/admin/' do
  	slim :admin_info
end

get '/admin/module' do
	slim :admin_module
end

