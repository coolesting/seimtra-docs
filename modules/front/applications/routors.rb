get '/' do
	slim :front
end

post "/form1" do
	params[:f1] + params[:f2] + params[:opt]
end
