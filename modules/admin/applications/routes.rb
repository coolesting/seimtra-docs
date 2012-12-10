get '/a' do
	redirect '/admin/'
end

get '/admin/' do
  	sys_tpl :admin_info
end

get '/admin/module' do
	sys_tpl :admin_module
end

