get '/system/panel' do
	set_title 'the info of system'
	@menus = {}
	@menu_names = []
	@links.each do | row |
		unless @menus.include? row[:menu]
			@menu_names << row[:menu]
			@menus[row[:menu]] = [] 
		end
		@menus[row[:menu]] << row 
	end
  	slim :system_panel
end

get '/system/module' do
	set_title 'the system modules'
	slim :system_module
end

get '/system/setting' do
	set_title 'the system settings'
	@settings = DB[:settings]
	slim :system_setting
end
