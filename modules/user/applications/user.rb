get '/system/user' do

	sys_opt :new
	@user = DB[:user]
	slim :system_user

end

get '/system/user/new' do

	sys_opt :save
	slim :system_user_form

end

get '/system/user/edit/:uid' do

	sys_opt :save, :remove
	@fields = DB[:user].filter(:uid => params[:uid]).all[0]
 	slim :system_user_form

end

post '/system/user/new' do

	user_valid params[:name], params[:pawd]
	user_add params[:name], params[:pawd]
	redirect "/system/user"

end

post '/system/user/edit/:uid' do

	user_valid params[:name], params[:pawd]

	if params[:opt] == "Remove"
		user_delete params[:uid]
	elsif params[:opt] == "Save"
		user_edit
	end

	redirect "/system/user"

end

get '/user/info' do

	@user_info = user_info
	slim :user_info

end

get '/user/logout' do

	user_logout
	redirect "/"

end

get '/user/login' do

	slim :user_login

end

post '/user/login' do

	user_valid params[:name], params[:pawd]
	user_login params[:name], params[:pawd]
	redirect "/user/info"

end

helpers do

	# == user_login?
	# check the current user whether logined
	#
	# == Argument
	# boolean value, the unlogin user will be redirect to login page if the value is true
	def user_login? redirect = false
		info = user_info
		if info[:uid] == 0 and redirect == true
			redirect '/user/login'
		else
			info[:uid]
		end
	end

	# == user_info
	# get the current user infomation if no uid be passed as parameter,
	# this method will check the current session that belongs which user, otherwise is unknown
	#
	# == Argument
	# uid, integer, default value is 0
	#
	# == Returned
	# a hash, the key have :uid, :name
	def user_info uid = 0

		infos 			= {}
		infos[:uid] 	= uid
		infos[:name] 	= 'unknown'

		if uid == 0
			if sid = request.cookies['sid']
				uid = DB[:session].filter(:sid => sid).get(:uid)
			end
		end

		if uid.to_i > 0
			infos[:name] = DB[:user].filter(:uid => uid).get(:name)
		end
		infos

	end

	def user_logout
		response.set_cookie "sid", ""
		user_session_remove request.cookies['sid']
	end

	def user_login name, pawd
		throw_error "The user is not existing." unless user_exist? name
		ds = DB[:user].filter(:name => name)
		require "digest/sha1"
		if ds.get(:pawd) == Digest::SHA1.hexdigest(pawd + ds.get(:salt))
			#update login time
			ds.update(:changed => Time.now)

			sid = Digest::SHA1.hexdigest(name + Time.now.to_s)

			#set sid to client cookie
			response.set_cookie "sid", sid

			#sign user in server
			user_session_update sid, ds.get(:uid)
		else
			throw_error "The username and password is not matching, or wrong."
		end
	end

	def user_delete uid
		DB[:user].filter(:uid => uid.to_i).delete
	end

	def user_edit
		throw_error "No uid." unless params[:uid]

		fields			= {}
		fields[:name]	= params[:name] if params[:name]
		
		if params[:pawd]
			ds = DB[:user].filter(:uid => params[:uid].to_i).all[0]
			unless ds[:pawd] == params[:pawd]
				fields[:pawd] = Digest::SHA1.hexdigest(params[:pawd] + ds[:salt])
			end
		end

		throw_error "Nothing to be update." if fields.empty? 
		DB[:user].filter(:uid => params[:uid].to_i).update(fields)
	end

	# == user_add
	# add a new user
	#
	# == Argument
	# name string
	# pawd string
	#
	# == Returned
	# return uid, otherwise is 0
	def user_add name, pawd
		fields 				= {}
		fields[:name] 		= name
		fields[:salt] 		= random_string 5
		fields[:created] 	= Time.now
		fields[:changed] 	= Time.now

		require "digest/sha1"
		fields[:pawd] 		= Digest::SHA1.hexdigest(pawd.to_s + fields[:salt])

		throw_error "The user is existing." if user_exist? name

		DB[:user].insert(fields)
		uid = DB[:user].filter(:name => name).get(:uid)
		uid ? uid : 0
	end

	def user_valid name, pawd
		throw_error "The username need to bigger than two size." unless name.length > 2	
		throw_error "The password need to bigger than two size." unless pawd.length > 2	
	end

	def user_exist? name
		uid = DB[:user].filter(:name => name).get(:uid)
		uid ? true : false
	end

	# == user_session_update
	# update the session by sid, if the session is not existing, 
	# create a new session for current uid
	#
	# == Argument
	# sid, string, the session id
	# uid, integer, the user id
	def user_session_update sid = "", uid = 0
		if ds = DB[:session].filter(:sid => sid)
			ds.update(:changed => Time.now)
		else
			DB[:session].insert(:sid => sid, :uid => uid.to_i, :changed => Time.now)
		end
	end

	def user_session_remove sid = nil
		if sid
			DB[:session].filter(:sid => sid).delete
		end
	end

end
