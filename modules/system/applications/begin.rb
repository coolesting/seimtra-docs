before '/system/*' do

	sys_title "Seimtra system!"

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :sys_opt, {}

	set :sys_msg, nil

	@fields		= {}

	@menus 		= DB[:menu]

	menu_name 	= @menus.filter(:link => request.path).get(:name)
	menu_des 	= @menus.filter(:link => request.path).get(:description)

	if menu_name and menu_des
		sys_title(menu_name.capitalize + " - " + menu_des)
	end

	#first menu
	@menus1	= {}

	#second menu
	@menus2	= {}

	@menus.each do | row |
		@menus1[row[:name]] = row[:link] if row[:preid] == 0
	end
	
end
