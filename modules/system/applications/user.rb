get '/_logout' do
	_logout
	redirect settings.home_page
end

get '/_login' do
	redirect settings.home_page if _user[:uid] != 0
	_tpl :_login
end

post '/_login' do
	_user_valid params[:name], params[:pawd]

	#user register 
	if params[:userstate] == 'new'
		if _var(:allow_register, :user) == 'yes'
			_user_add params[:name], params[:pawd] 
		else
			_throw L[:'the register is closed']
		end
	end
	#user login
	_login params[:name], params[:pawd]

	return_page = request.cookies['ref_url'] ? request.cookies['ref_url'] : settings.home_page
	redirect return_page
end

helpers do

	# == _login?
	# check the current user whether it is existing in session
	#
	# == Argument
	# string, the unknown user will be redirect to the path
	def _login? redirect_path = nil
		info = _user
		
		redirect_path = @_login_path if redirect_path == nil
		if info[:uid] < 1 and request.path != redirect_path
			response.set_cookie "ref_url", :value => request.path, :path => "/"
			redirect redirect_path
		else
			#update the session time
			_session_update info[:sid], info[:uid]
			info[:uid]
		end
	end

	# == _level
	# user level, if the user level less than the level given, it will be throw
	def _level level
		error L[:'your level is too low'] if _user[:level].to_i < level.to_i
	end

	# == _user
	# get the current user infomation by uid,
	# this method will checks the uid whether it is existing in current session
	#
	# == Argument
	# uid, integer, default value is 0
	#
	# == Returned
	# a hash, the key have :uid, :name
	def _user uid = 0
		infos 			= {}
		infos[:uid] 	= uid
		infos[:name] 	= 'unknown'
		infos[:level] 	= 0
		infos[:sid] 	= ''

		if uid == 0
			if sid = request.cookies['sid']
				uid = _session_has sid
			end
		end

		if uid.to_i > 0
			ds = DB[:_user].filter(:uid => uid)
			infos[:uid]		= uid
			infos[:name] 	= ds.get(:name)
			infos[:level] 	= ds.get(:level)
			infos[:sid] 	= sid
		end
		infos
	end

	def _logout
		sid = request.cookies['sid']
		#remove from client
		response.set_cookie "sid", :value => "", :path => "/"
		#clear from server
		_session_remove sid
	end

	def _login name, pawd

		_throw L[:'the user is not existing'] unless _user_exist? name
		ds = DB[:_user].filter(:name => name)

		#verity user
		require "digest/sha1"
		if ds.get(:pawd) == Digest::SHA1.hexdigest(pawd + ds.get(:salt))
			#create a sid for current user login
			sid = Digest::SHA1.hexdigest(name + Time.now.to_s)

			#set sid to client cookie
			response.set_cookie "sid", :value => sid, :path => "/"

			#set sid at database
			_session_create sid, ds.get(:uid)
		else
			_throw L[:'the password is wrong']
		end

	end

	def _user_delete uid
		DB[:_user].filter(:uid => uid.to_i).delete
		DB[:_sess].filter(:uid => uid.to_i).delete
	end

	def _user_edit fields

		if fields.include? :uid 
			_throw L[:'no user id'] 
		else
			uid = fields[:uid].to_i
		end

		ds = DB[:_user].filter(:uid => uid).all[0]
		if ds
			update_fields = {}

			#password
			if fields[:pawd] and fields[:pawd].strip.size > 2
				update_fields[:pawd] = Digest::SHA1.hexdigest(fields[:pawd] + ds[:salt])
			end

			#user level
			update_fields[:level] = fields[:level] if fields[:level] != ds[:level]

			#user name
			if fields[:name] and _user_name?(fields[:name]) == false
				update_fields[:name] = fields[:name] 
			end

			DB[:_user].filter(:uid => uid).update(update_fields)
		end

	end

	#query the user name whether or not exist in database, if it is existing then return true
	#otherwise, is false
	def _user_name? name
		DB[:_user].filter(:name => name).empty? ? false : true
	end

	# == _user_add
	# add a new user
	#
	# == Arguments
	# name string
	# pawd string
	#
	# == Returned
	# return uid, otherwise is 0
	def _user_add name, pawd

		fields 				= {}
		fields[:name] 		= name
		fields[:salt] 		= _random_string 5
		fields[:created] 	= Time.now

		require "digest/sha1"
		fields[:pawd] 		= Digest::SHA1.hexdigest(pawd.to_s + fields[:salt])

		_throw L[:'the user is existing'] if _user_exist? name

		DB[:_user].insert(fields)
		uid = DB[:_user].filter(:name => name).get(:uid)
		uid ? uid : 0

	end

	def _user_valid name, pawd
		_throw L[:'the username need to bigger than two size'] if name.strip.size < 2
		_throw L[:'the password need to bigger than two size'] if pawd.strip.size < 2
	end

	def _user_exist? name
		uid = DB[:_user].filter(:name => name).get(:uid)
		uid ? true : false
	end

	# == _session_update
	# update the session time by sid and uid, 
	#
	# == Argument
	# sid, string, the session id
	# uid, integer, the user id
	def _session_update sid = "", uid = 0
		ds = DB[:_sess].filter(:sid => sid, :uid => uid.to_i)
		ds.update(:changed => Time.now) if ds.count > 0
	end

	def _session_remove sid = nil
		DB[:_sess].filter(:sid => sid).delete if sid
	end

	def _session_create sid, uid
		DB[:_sess].insert(:sid => sid, :uid => uid, :changed => Time.now)
	end

	#the user do nothing in the timeout time, the session will be remove, automatically
	#return the uid
	def _session_has sid
		uid = 0
		ds = DB[:_sess].filter(:sid => sid)
		if ds.get(:sid)
			timeout = ds.get(:timeout).to_i > 0 ? ds.get(:timeout).to_i : 30

			#remove the session, if timeout
			curtime = Time.now.strftime("%y%m%d%h%m").to_i
			if (curtime - ds.get(:changed).strftime("%y%m%d%h%m").to_i) > timeout
				ds.delete
			else
				uid = ds.get(:uid)
			end
		end
		uid
	end

end
