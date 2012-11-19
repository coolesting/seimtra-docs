
get '/errors/:msg' do
	@error_msg = params[:msg]
	slim :errors
end
