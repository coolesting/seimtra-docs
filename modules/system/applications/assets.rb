# the format of url as the following
#
# /css/moduleName
# /ccs/moduleName_fileName
# /images/moduleName
# /images/moduleName_fileName
#
# the route path /css/custom.css  , the real path, /modules/custom/css/custom.css
# the route path /css/custom_layout.css	, the real path,  /modules/custom/css/layout.css
get '/css/:file_name' do
	_assets params[:file_name], 'css'
end

get '/images/:file_name' do
	_assets params[:file_name], 'images'
end

get '/js/:file_name' do
	_assets params[:file_name], 'js'
end

require 'sass'

configure do
	set :sass, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
end

get '/css/sass.css' do
	sass :index
end
