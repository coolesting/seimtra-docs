
get '/errors/:msg' do
	@error_msg = params[:msg]
	sys_slim :errors
end
