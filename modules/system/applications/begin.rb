before '/system/*' do

	set_title "Seimtra system!"

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :opt_events, {}

	set :msg, nil

	@fields		= {}

	@panel 		= DB[:panel]

	panel 		= @panel[:link => request.path]

	if panel
		set_title(panel[:name].capitalize + " - " + panel[:description])
	end

	@status_bar = @panel.filter(:status => 1).all

end
