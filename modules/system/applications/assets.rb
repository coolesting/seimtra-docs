#/css/modulename/filename => the real path as 'modules/modulename/css/filename'
get '/_assets/:module/:assets/:filename' do
	path = settings.root + "/modules/#{params[:module]}/#{params[:assets]}/#{params[:filename]}"
	send_file path, :type => params[:assets].to_sym
end

require 'sass'
configure do
	set :sass, :cache => true, :cahce_location => './tmp/sass-cache', :style => :compressed
end

get '/css/sass.css' do
	sass :index
end

helpers do

	def _public path, domain = nil
		path
	end

	def _file path, domain = nil
		"/_file/get/#{path}"
	end

	def _assets path, domain = nil
		"/_assets#{path}"
	end

end
