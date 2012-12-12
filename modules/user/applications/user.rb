get '/user/info' do

	user_login? true
	@user_info = user_info
	sys_tpl :user_info

end

get '/user/logout' do

	user_logout
	redirect "/"

end

get '/user/login' do

	redirect '/user/info' if user_info[:uid] != 0
	sys_tpl :user_login

end

post '/user/login' do

	user_valid params[:name], params[:pawd]
	user_login params[:name], params[:pawd]
	redirect settings.home_page

end

helpers do

	# == user_login?
	# check the current user whether or not login
	#
	# == Argument
	# string, the unknown user will be redirect to the path
	def user_login? redirect_path = settings.home_page

		info = user_info
		
		if info[:uid] < 1 and request.path != redirect_path
			redirect redirect_path
		else
			#update the session time
			user_session_update info[:sid], info[:uid]
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
		infos[:sid] 	= ''

		if uid == 0
			if sid = request.cookies['sid']
				uid = DB[:session].filter(:sid => sid).get(:uid)
			end
		end

		if uid.to_i > 0
			infos[:uid]		= uid
			infos[:name] 	= DB[:user].filter(:uid => uid).get(:name)
			infos[:sid] 	= sid
		end
		infos

	end

	def user_logout

		response.set_cookie "sid", :value => "", :path => "/"
		user_session_remove request.cookies['sid']

	end

	def user_login name, pawd

		sys_throw "The user is not existing." unless user_exist? name
		ds = DB[:user].filter(:name => name)

		require "digest/sha1"
		if ds.get(:pawd) == Digest::SHA1.hexdigest(pawd + ds.get(:salt))
			#update login time
			ds.update(:changed => Time.now)

			sid = Digest::SHA1.hexdigest(name + Time.now.to_s)

			#set sid to client cookie
			response.set_cookie "sid", :value => sid, :path => "/"

			#set sid at server
			DB[:session].insert(:sid => sid, :uid => ds.get(:uid), :changed => Time.now)
		else
			sys_throw "The username and password is not matching, or wrong."
		end

	end

	def user_delete uid

		DB[:user].filter(:uid => uid.to_i).delete

	end

	def user_edit fields

		if fields.include? :uid 
			sys_throw "No uid." 
		else
			uid = fields[:uid].to_i
		end

		ds = DB[:user].filter(:uid => uid).all[0]
		pawd = Digest::SHA1.hexdigest(fields[:pawd] + ds[:salt])
		DB[:user].filter(:uid => uid).update(:pawd => pawd)

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

		sys_throw "The user is existing." if user_exist? name

		DB[:user].insert(fields)
		uid = DB[:user].filter(:name => name).get(:uid)
		uid ? uid : 0

	end

	def user_valid name, pawd

		sys_throw "The username need to bigger than two size." if name.strip.size < 2
		sys_throw "The password need to bigger than two size." if pawd.strip.size < 2

	end

	def user_exist? name

		uid = DB[:user].filter(:name => name).get(:uid)
		uid ? true : false

	end

	# == user_session_update
	# update the session time by sid and uid, 
	#
	# == Argument
	# sid, string, the session id
	# uid, integer, the user id
	def user_session_update sid = "", uid = 0

		ds = DB[:session].filter(:sid => sid, :uid => uid.to_i)
		if ds.count > 0
			ds.update(:changed => Time.now)
		end

	end

	def user_session_remove sid = nil

		if sid
			DB[:session].filter(:sid => sid).delete
		end

	end

end
