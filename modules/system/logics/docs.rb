
#set the default page
get '/' do
#  	pass if request.path_info == '/'
	status, headers, body = call! env.merge("PATH_INFO" => _var(:home, :page))
end

get '/_index' do
	_tpl :_index
end
