before '/admin/*' do

	_login?
	_level 99

	@title = L[:'welcome to administrator page']

	#a variable, search condition options in layout template
	@search	= {}

	@rightbar = []

	#the top menu of admin_layout.slim
	@menus = _menu 'admin'

# 	@menus = DB[:_menu].filter(:tid => _tags('admin')).order(:order)
# 	halt L[:'no admin menu'] if @menus.empty?

# 	#fetch the current available menu item from request path of url
# 	menu_curr	= @menus.filter(:link => request.path)
# 	if menu_curr.get(:mid).class.to_s == "NilClass"
# 		path_arr = request.path.split "/"
# 		while menu_curr.get(:mid).class.to_s == "NilClass"
# 			path_str = ""
# 			path_arr.pop
# 			path_str += path_arr.join("/")
# 			menu_curr = @menus.filter(:link => path_str)
# 		end
# 	end
# 	
# 	menu_name 	= menu_curr.get(:name)
# 	menu_des 	= menu_curr.get(:description)
# 
# 	@menu1_focus = @menu2_focus = menu_name
# 
# 	#get the focus item of the top menu , currentlly
# 	if menu_curr.get(:preid) == 0
# 		menu1_mid = menu_curr.get(:mid) 
# 		@menu2_focus = ""
# 	#the second menu on focus
# 	else
# 		menu1_mid = menu_curr.get(:preid)
# 		#need to set the top menu
# 		@menu1_focus = @menus.filter(:mid => menu1_mid).get(:name)
# 	end
# 
# 	if menu_name and menu_des
# 		@title = menu_name + " - " + menu_des
# 	end
#  
# 	#menu_link => {:name => "link1", :name2 => "link2" ,,,}
# 	@menu_link = {}
# 
# 	#menu_name => {:top_menu_name1 => [:sec_menu_name1, :sec_menu_name,], :top_menu_name2 => {:sec_menu_name1 ,,,} ,,,}
# 	@menu_name = {}
# 	@menu_mid = {}
# 	@menus.each do | row |
# 		@menu_link[row[:name]] = row[:link]
# 		@menu_mid[row[:mid]]	= row[:name]
# 		#1 level menu name
# 		@menu_name[row[:name]] = [] if row[:preid] == 0
# 	end
# 
# 	@menus.each do | row |
# 		#2 level menu name
# 		if @menu_mid.has_key? row[:preid]
# 			@menu_name[@menu_mid[row[:preid]]] << row[:name] if @menu_name.include? @menu_mid[row[:preid]]
# 		end
# 	end
# 
# 	require 'json'
# 	@json_menu_link = JSON.pretty_generate @menu_link
# 	@json_menu_name = JSON.pretty_generate @menu_name

end

