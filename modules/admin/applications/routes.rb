get '/a' do
	redirect '/admin/'
end

get '/admin/' do
  	sys_slim :admin_info
end

get '/admin/module' do
	sys_slim :admin_module
end

