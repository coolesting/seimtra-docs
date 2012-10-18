before do

	#request query string
	@qs	= {}
	if qs = request.query_string
		qs.split("&").each do | item |
			key, val = item.split "="
			if val and val.index '+'
				@qs[key.to_sym] = val.gsub(/[+]/, ' ')
			else
				@qs[key.to_sym] = val
			end
		end
	end

end

before '/system/*' do

	#===========
	#=== 01, define the setting
	#===========
	#set the specifying template for admin view

	@title = "Seimtra system!"

	set :slim, :layout => :system_layout

	#the operation bar
	set :sys_opt, {}

	set :sys_msg, nil

	#a variable, search condition options of layout template
	@search		= {}

	@fields		= {}


	#===========
	#=== 02, the top menu of layout template
	#===========
	@menus 		= DB[:menu].filter(:type => 'system').order(:order)

	#fetch the current available menu item from request path of url
	menu_curr	= @menus.filter(:link => request.path)
	if menu_curr.get(:mid).class.to_s == "NilClass"
		path_arr = request.path.split "/"
		while menu_curr.get(:mid).class.to_s == "NilClass"
			path_str = ""
			path_arr.pop
			path_str += path_arr.join("/")
			menu_curr = @menus.filter(:link => path_str)
		end
	end
	
	menu_name 	= menu_curr.get(:name)
	menu_des 	= menu_curr.get(:description)

	@menu1_focus = @menu2_focus = menu_name

	#get the focus item of the top menu , currentlly
	if menu_curr.get(:preid) == 0
		menu1_mid = menu_curr.get(:mid) 
		@menu2_focus = ""
	#the second menu on focus
	else
		menu1_mid = menu_curr.get(:preid)
		#need to set the top menu
		@menu1_focus = @menus.filter(:mid => menu1_mid).get(:name)
	end

	if menu_name and menu_des
		@title = menu_name + " - " + menu_des
	end
 
	#menu_link => {:name => "link1", :name2 => "link2" ,,,}
	@menu_link = {}

	#menu_name => {:top_menu_name1 => [:sec_menu_name1, :sec_menu_name,], :top_menu_name2 => {:sec_menu_name1 ,,,} ,,,}
	@menu_name = {}
	@menu_mid = {}
	@menus.each do | row |
		@menu_link[row[:name]] = row[:link]
		@menu_mid[row[:mid]]	= row[:name]
		#1 level menu name
		@menu_name[row[:name]] = [] if row[:preid] == 0
	end

	@menus.each do | row |
		#2 level menu name
		if @menu_mid.has_key? row[:preid]
			@menu_name[@menu_mid[row[:preid]]] << row[:name]
		end
	end

	require 'json'
	@json_menu_link = JSON.pretty_generate @menu_link
	@json_menu_name = JSON.pretty_generate @menu_name


	#==========
	#=== 03, the pagination parameters
	#==========
	@page_size = 30
	@page_curr = 1 
	@page_curr = @qs[:page_curr].to_i if @qs.include? :page_curr and @qs[:page_curr].to_i > 0

end

