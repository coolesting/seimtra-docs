before '/system/*' do

	sys_title "Seimtra system!"

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :sys_opt, {}

	set :sys_msg, nil

	@fields		= {}

	@panel 		= DB[:panel]

	panel_name 	= @panel.filter(:link => request.path).get(:name)
	panel_des 	= @panel.filter(:link => request.path).get(:description)

	if panel_name and panel_des
		sys_title(panel_name.capitalize + " - " + panel_des)
	end

	@status_bar = @panel.filter(:status => 1).all

	@menus = {}
	@menu_names = []
	@panel.each do | row |
		unless @menus.include? row[:menu]
			@menu_names << row[:menu]
			@menus[row[:menu]] = [] 
		end
		@menus[row[:menu]] << row 
	end
	
	@menus_json = sys_json @menus
end
