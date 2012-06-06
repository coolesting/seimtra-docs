before '/system/*' do

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :opt_events, {}

	set :msg, nil

	@fields	= {}

	@panel 	= DB[:panel]
	panel 	= @panel[:link => request.path]

	set_title(panel[:name].capitalize + " - " + panel[:description])

	@status_bar = @panel.filter(:status => 1).all

end
