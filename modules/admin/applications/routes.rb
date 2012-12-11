get '/a' do
	redirect '/admin/'
end

get '/admin/' do
  	sys_tpl :admin_info
end

get '/admin/module' do
	sys_tpl :admin_module
end

get '/admin/module/opened/:opened/:mid' do
	opened = params[:opened] == 'on' ? 'on' : 'off'
	DB[:module].filter(:mid => params[:mid]).update(:opened => opened)
	redirect back
end
