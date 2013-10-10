get '/a' do
 	redirect '/admin/'
end

get '/admin/' do
  	_tpl :_info
end

####################
#	module
####################
get '/admin/_mods' do
	_prepare(:search => :enable)
	_view :_mods
end


####################
#	documents
####################
get '/admin/_docs' do
	_prepare(:search => :enable)
	_admin :_docs
end

post '/admin/_docs' do
	_submit :_docs
end


####################
#	language
####################
get '/admin/_lang' do
	_prepare(:search => :enable)
	_admin :_lang
end

post '/admin/_lang' do
	_submit :_lang
end


####################
#	variables
####################
get '/admin/_vars' do
	_prepare(:search => :enable)
	_admin :_vars
end

post '/admin/_vars' do
	_submit :_vars
end

####################
#	rule
####################
get '/admin/_rule' do
	_prepare(:search => :enable)
	_admin :_rule
end

post '/admin/_rule' do
	_submit :_rule
end


####################
#	tag
####################
get '/admin/_tags' do
	_prepare(:search => :enable)
	_admin :_tags
end

post '/admin/_tags' do
	_submit :_tags
end


####################
#	user and rule
####################
get '/admin/_urul' do
	_prepare(:search => :enable)
	_admin :_urul
end

post '/admin/_urul' do
	_submit :_urul
end


####################
#	session
####################
get '/admin/_sess' do
	_prepare(:search => :enable)
	_admin :_sess
end

post '/admin/_sess' do
	_submit :_sess
end


####################
#	task
####################
get '/admin/_task' do
	_prepare(:search => :enable)
	_admin :_task
end

post '/admin/_task' do
	_submit :_task
end


####################
#	note
####################
get '/admin/_note' do
	_prepare(:search => :enable)
	_admin :_note
end

post '/admin/_note' do
	_submit :_note
end


####################
#	menu
####################
get '/admin/_menu' do
	_prepare(:search => :enable)
	_admin :_menu
end

post '/admin/_menu' do
	_submit :_menu
end

