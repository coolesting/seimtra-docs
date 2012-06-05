before '/system/*' do

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :opt_events, {}

	set :msg, nil

	@fields	= {}

	@links = DB[:links]
	set_title @links[:link => request.path][:description]

	@status_bar = @links.filter(:status => 1).all

end
