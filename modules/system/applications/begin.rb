before '/system/*' do

	sys_title "Seimtra system!"

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#a operation bar
	set :sys_opt, {}

	set :sys_msg, nil

	@fields		= {}

	@menus 		= DB[:menu]

	menu_curr	= @menus.filter(:link => request.path)
	menu_name 	= menu_curr.get(:name)
	menu_des 	= menu_curr.get(:description)
	menu_mid	= menu_curr.get(:mid)

	if menu_name and menu_des
		sys_title(menu_name.capitalize + " - " + menu_des)
	end

	#first menu
	@menus1	= {}

	#second menu
	@menus2	= {}

	@menus.each do | row |
		@menus1[row[:name]] = row[:link] if row[:preid] == 0
		@menus2[row[:name]] = row[:link] if row[:preid] == menu_mid
	end

end
