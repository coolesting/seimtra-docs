get '/a' do
 	redirect '/admin/'
end

get '/admin/' do
  	_tpl :_info
end

