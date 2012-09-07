before '/system/*' do

	@title = "Seimtra system!"

	#set the specifying template for admin view
	set :slim, :layout => :system_layout

	#the operation bar
	set :sys_opt, {}

	set :sys_msg, nil

	#request.query_string
	@qs	= {}
	if qs = request.query_string
		qs.split("&").each do | item |
			key, val = item.split "="
			@qs[key.to_sym] = val
		end
	end

	@fields		= {}

	#the top menu of administration layout
	@menus 		= DB[:menu].filter(:type => 'system').order(:order)

	menu_curr	= @menus.filter(:link => request.path)
	menu_name 	= menu_curr.get(:name)
	menu_des 	= menu_curr.get(:description)

	@menu1_focus = @menu2_focus = menu_name

	#this is a top menu
	if menu_curr.get(:preid) == 0
		menu1_mid = menu_curr.get(:mid) 
		@menu2_focus = ""
	#it is second menu
	else
		menu1_mid = menu_curr.get(:preid)
		#need to set the top menu
		@menu1_focus = @menus.filter(:mid => menu1_mid).get(:name)
	end

	if menu_name and menu_des
		@title = menu_name.capitalize + " - " + menu_des
	end

	#first menu
	@menus1	= {}

	#second menu
	@menus2	= {}

	@menus.each do | row |
		if row[:preid] == 0
			@menus1[row[:name]] = row[:link] 
		elsif row[:preid] == menu1_mid
			@menus2[row[:name]] = row[:link] 
		end
	end

	#the pagination parameters
	@page_size = 30
	@page_curr = 1 
	@page_curr = @qs[:page_curr].to_i if @qs.include? :page_curr and @qs[:page_curr].to_i > 0
end
