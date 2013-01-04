get '/a' do
 	redirect '/admin/'
end

get '/admin/' do
  	_tpl :admin_info
end

