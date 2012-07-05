# the format of url as the following
#
# /css/moduleName
# /ccs/moduleName_fileName
# /images/moduleName
# /images/moduleName_fileName
#
# /css/custom.css  			=> read the file /modules/custom/css/custom.css
# /css/custom_layout.css	=> read the file /modules/custom/css/layout.css
get '/css/:file_name' do
	sys_file params[:file_name], 'css'
end

get '/images/:file_name' do
	sys_file params[:file_name], 'images'
end

get '/js/:file_name' do
	sys_file params[:file_name], 'js'
end
