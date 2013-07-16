before '/admin/*' do

	_login? _var(:home, :page)
	_level? _var(:administratorlevel, :system)

	@t[:title] 	= L[:'welcome to administrator page']

	#search condition options of layout template
	@search		= {}

	@rightbar 	= []

	#the top menu of admin_layout.slim
	@menus 		= _menu :admin

end

