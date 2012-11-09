after '/admin/*' do
	#set the specifying template for front-page
	set :slim, :layout => :layout
	set :admin_msg, nil
end
