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
	_user_add params[:name], params[:pawd] if params[:register] == "yes"
	_login params[:name], params[:pawd]
	redirect settings.home_page
end

helpers do

	# == _login?
	# check the current user whether or not login
	#
	# == Argument
	# string, the unknown user will be redirect to the path
	def _login? redirect_path = settings.home_page

		info = _user
		
		if info[:uid] < 1 and request.path != redirect_path
			redirect redirect_path
		else
			#update the session time
			_session_update info[:ticket], info[:uid]
			info[:uid]
		end

	end

	# == _user
	# get the current user infomation if no uid be passed as parameter,
	# this method will check the current session that belongs which user, otherwise is unknown
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
		infos[:ticket] 	= ''

		if uid == 0
			if ticket = request.cookies['ticket']
				uid = _session_has ticket
			end
		end

		if uid.to_i > 0
			infos[:uid]		= uid
			infos[:name] 	= DB[:_user].filter(:uid => uid).get(:name)
			infos[:ticket] 	= ticket
		end
		infos

	end

	def _logout

		ticket = request.cookies['ticket']

		#remove from client
		response.set_cookie "ticket", :value => "", :path => "/"
		_ticket_remove ticket

	end

	def _ticket_remove ticket
		#remove from database
		DB[:_tick].filter(:name => ticket).delete

		#remvoe from session
		_session_remove ticket
	end

	def _login name, pawd

		_throw "The user is not existing." unless _user_exist? name
		ds = DB[:_user].filter(:name => name)

		#verity user
		require "digest/sha1"
		if ds.get(:pawd) == Digest::SHA1.hexdigest(pawd + ds.get(:salt))
			#validation user success
			#create a ticket for current user login
			ticket = Digest::SHA1.hexdigest(name + Time.now.to_s)

			#set ticket to client cookie
			response.set_cookie "ticket", :value => ticket, :path => "/"

			#set ticket at database
			DB[:_tick].insert(:name => ticket, :uid => ds.get(:uid), :created => Time.now, :agent => request.user_agent, :ip => request.ip)

			#set ticket to session
			_session_create ticket, ds.get(:uid)
		else
			_throw "The username and password is not matching, or wrong."
		end

	end

	def _user_delete uid
		DB[:_user].filter(:uid => uid.to_i).delete
		DB[:_tick].filter(:uid => uid.to_i).delete
	end

	def _user_edit fields

		if fields.include? :uid 
			_throw "No uid." 
		else
			uid = fields[:uid].to_i
		end

		ds = DB[:_user].filter(:uid => uid).all[0]
		if ds
			update_fields = {}

			if fields[:pawd].strip.size > 2
				update_fields[:pawd] = Digest::SHA1.hexdigest(fields[:pawd] + ds[:salt])
			end

			update_fields[:level] = fields[:level] if fields[:level] != ds[:level]

			DB[:_user].filter(:uid => uid).update(update_fields)
		end

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

		_throw "The user is existing." if _user_exist? name

		DB[:_user].insert(fields)
		uid = DB[:_user].filter(:name => name).get(:uid)
		uid ? uid : 0

	end

	def _user_valid name, pawd
		_throw "The username need to bigger than two size." if name.strip.size < 2
		_throw "The password need to bigger than two size." if pawd.strip.size < 2
	end

	def _user_exist? name
		uid = DB[:_user].filter(:name => name).get(:uid)
		uid ? true : false
	end

	# == _session_update
	# update the session time by ticket and uid, 
	#
	# == Argument
	# ticket, string, the ticket name
	# uid, integer, the user id
	def _session_update ticket = "", uid = 0
		ds = DB[:_sess].filter(:ticket => ticket, :uid => uid.to_i)
		ds.update(:changed => Time.now) if ds.count > 0
	end

	def _session_remove ticket = nil
		DB[:_sess].filter(:ticket => ticket).delete if ticket
	end

	def _session_remove_by_timeout timeout = 30

		curtime = Time.now.strftime("%Y%m%d%H%M").to_i
		DB[:_sess].all.each do | row |
			if (curtime - row[:changed].strftime("%Y%m%d%H%M").to_i) > timeout
				DB[:_sess].filter(:ticket => row[:ticket], :uid => row[:uid]).delete
			end
		end

	end

	def _session_remove_by_self
		DB[:_sess].where(:uid => uid).exclude(ticket => request.cookies['ticket']).delete
	end

	def _session_create ticket, uid
		DB[:_sess].insert(:ticket => ticket, :uid => uid, :changed => Time.now)
	end

	def _session_has ticket
		DB[:_sess].filter(:ticket => ticket).get(:uid)
	end

end
