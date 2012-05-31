before '/admin/*' do
	@title = "Administration console"

	#get the top menu of administration
	@links_admin = DB[:links].filter(:bid => 2).order(:order).reverse

	#set the specifying template for admin view
	set :slim, :layout => :admin_layout

	#a operation bar
	set :opt_events, {}

	set :msg, nil
end
