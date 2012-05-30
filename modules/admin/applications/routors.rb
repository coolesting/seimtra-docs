get '/admin/modules' do
	@title += ' the system modules'
	slim :modules
end

get '/admin/settings' do
	@title += ' the system settings'
	@settings = DB[:settings]
	slim :settings
end

get '/admin/info' do
	@title += ' the back ground page'
	slim :admin
end

get '/admin/info/t' do
	@title += ' the back ground page'
	slim :admin
end
