before '/admin/*' do

	_login?
	_level _var(:administratorlevel, :system)

	@title 		= L[:'welcome to administrator page']

	#search condition options of layout template
	@search		= {}

	@rightbar 	= []

	#the top menu of admin_layout.slim
	@menus 		= _menu :admin

end

