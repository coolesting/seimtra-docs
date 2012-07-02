get '/system/user' do

	opt_events :new
	@user = DB[:user]
	slim :system_user

end

get '/system/user/new' do

	opt_events :save
	slim :system_user_form

end

get '/system/user/edit/:uid' do

	opt_events :save, :remove
	@fields = DB[:user].filter(:uid => params[:uid]).all[0]
 	slim :system_user_form

end

post '/system/user/new' do

	user_valid(params[:name], params[:pawd])
	user_add(params[:name], params[:pawd])
	redirect "/system/user"

end

post '/system/user/edit/:uid' do

	user_valid(params[:name], params[:pawd])

	if params[:opt] == "Remove"
		user_delete params[:uid]
	elsif params[:opt] == "Save"
		fields = {}
		params.each do | key, val |
			fields[key.to_sym] = val
		end
		user_update fields
	end

	redirect "/system/user"

end

helpers do

	# delete a user
	# @uid, integer, delete record with the key id
	def user_delete uid
		DB[:user].filter(:uid => uid.to_i).delete
	end

	# update the basic user info
	# @params, hash, the key-value likes params[:uid], params[:name], params[:pawd]
	def user_update params
		throw_error "No uid." unless params.include? :uid

		fields			= {}
		fields[:name]	= params[:name] if params.include? :name
		
		if params.include? :pawd
			ds = DB[:user].filter(:uid => params[:uid].to_i).all[0]
			unless ds[:pawd] == params[:pawd]
				fields[:pawd] = Digest::SHA1.hexdigest(params[:pawd] + ds[:salt])
			end
		end

		throw_error "Nothing to be update." if fields.empty? 
		DB[:user].filter(:uid => params[:uid].to_i).update(fields)
	end
	
	# add a new user
	# @name string
	# @pawd string
	# @return user id, otherwise is 0
	def user_add name, pawd
		fields 				= {}
		fields[:name] 		= name
		fields[:salt] 		= random_string 5
		fields[:created] 	= Time.now
		fields[:changed] 	= Time.now

		require "digest/sha1"
		fields[:pawd] 		= Digest::SHA1.hexdigest(pawd.to_s + fields[:salt])

		uid = 0
		unless user_exist? name
			DB[:user].insert(fields)
			uid = DB[:user].filter(:name => name).get(:uid)
		end
		uid
	end

	def user_valid name, pawd
		return false unless name.length > 2	
		return false unless pawd.length > 2	
		true
	end

	def user_exist? name
		uid = DB[:user].filter(:name => name).get(:uid)
		uid ? true : false
	end

	def user_process_fields data = {}
		
		default_values = {
			:uid		=> '',
			:name		=> '',
			:pawd		=> '',
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

		unless data.empty?

			if data.include? :no_null
				data[:no_null].each do | field |
					throw_error "The #{fields} can not be empty." if field == ""
				end
			end

		end

	end

end
