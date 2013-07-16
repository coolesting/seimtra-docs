get '/_logout' do
	_logout
end

get '/_login' do
	redirect _var(:after_login, :page) if _user[:uid] > 0
	@qs[:come_from] = request.referer unless @qs.include?(:come_from) 
	_tpl :_login
end

get '/_register' do
	if _var(:allow_register, :user) == 'yes'
		_tpl :_register
	else
		redirect _var(:login, :page)
	end
end

post '/_login' do
	data = _user_data
	_set_fields [], data, true
	_user_valid_fields

	#user register 
	if params[:userstate] == 'new'
		if _var(:allow_register, :user) == 'yes'
			_user_add @f
		else
			_throw L[:'the register is closed']
		end
	end

	#user login
	_login params[:name], params[:pawd]

	#return
	return_page = @qs.include?(:come_from) ? @qs[:come_from] : _var(:after_login, :page)
	redirect return_page
end

helpers do

	# == _login?
	# check the current user whether it is existing in session
	#
	# == Argument
	# string, the unknown user will be redirect to the path
	def _login? redirect_url = nil
		info = _user
		redirect_url ||= _var(:login, :page)
		if info[:uid] < 1 and request.path != redirect_url
			#response.set_cookie "ref_url", :value => request.path, :path => "/"
			@qs[:come_from] = request.path
			redirect _url2(redirect_url)
		else
			#update the session time
			_session_update info[:sid], info[:uid]
			info[:uid]
		end
	end

	# == _level
	# user level, if the user level less than the level given, it will be throw
	def _level? level
		error L[:'your level is too low'] if _user[:level].to_i < level.to_i
	end

	def _rule? name
		uid = _user[:uid]
		ds = DB[:_rule].filter(:name => name.to_s)
		if rid = ds.get(:rid)
			DB[:_urul].filter(:uid => uid, :rid => rid).empty? ? false : true
		end
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

	def _logout return_url = nil
		return_url ||= _var(:after_login, :page)
		sid = request.cookies['sid']
		#remove from client
		response.set_cookie "sid", :value => "", :path => "/"
		#clear from server
		_session_remove sid
		redirect return_url
	end

	def _login name, pawd
		ds = DB[:_user].filter(:name => name)
		if ds.empty?
			_throw L[:'the user is not existing'] unless _user? name
		else
			#verity user
			require "digest/sha1"
			if ds.get(:pawd) == Digest::SHA1.hexdigest(pawd + ds.get(:salt))
				#create a sid for current user login
				sid = Digest::SHA1.hexdigest(name + Time.now.to_s)

				#set sid to client cookie
				if params[:rememberme] == 'yes'
					expires = Time.now + 3600*24*_var(:timeout_of_login, :system).to_i
					response.set_cookie "sid", :value => sid, :path => "/", :expires => expires
				else
					response.set_cookie "sid", :value => sid, :path => "/"
				end


				#set sid at database
				_session_create sid, ds.get(:uid)
			else
				_throw L[:'the password is wrong']
			end
		end
	end

	def _user_delete uid
		DB[:_user].filter(:uid => uid.to_i).delete
		DB[:_sess].filter(:uid => uid.to_i).delete
	end

	def _user_edit f
		_throw L[:'no user id'] unless f.include? :uid
		uid = f[:uid].to_i

		ds = DB[:_user].filter(:uid => uid)
		unless ds.empty?
			update_fields = {}

			#password
			update_fields[:pawd] = Digest::SHA1.hexdigest(f[:pawd] + ds.get(:salt))

			#user level
			update_fields[:level] = f[:level] if f[:level] != ds.get(:level)

			#user name
			update_fields[:name] = f[:name] if _user?(f[:name]) == 0

			DB[:_user].filter(:uid => uid).update(update_fields)
		end
	end

	#check the user by name , if existing, return uid, others is 0
	def _user? name
		uid = DB[:_user].filter(:name => name).get(:uid)
		uid ? true : false
	end

	# == _user_add
	# add a new user
	#
	# == Arguments
	# an array includes name, pawd, level fields. 
	#
	# == Returned
	# return uid, otherwise is 0
	def _user_add f = {}
		f[:salt] 		= _random_string 5
		f[:created] 	= Time.now

		require "digest/sha1"
		f[:pawd] 		= Digest::SHA1.hexdigest(f[:pawd] + f[:salt])

		_throw L[:'the user is existing'] if _user? f[:name]

		DB[:_user].insert(f)
		uid = DB[:_user].filter(:name => f[:name]).get(:uid)
		uid ? uid : 0
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
