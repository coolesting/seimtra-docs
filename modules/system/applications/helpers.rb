helpers do

	#return path + query_string
	def _url path, options = {}
		str = path
		options.each do | ok, ov |
			@qs[ok.to_sym] = ov
		end
		unless @qs.empty?
			str += '?'
			@qs.each do | k, v |
				str = str + k.to_s + '=' + v.to_s + '&'
			end
		end
		str
	end

	#throw out the message, and redirect back
	def _throw str
		response.set_cookie 'msg', :value => str, :path => '/'
		redirect back
	end

	#set the message if get a parameter, otherwise returns the @str value
	def _msg str = ''
		unless str == ''
			@msg = str
			response.set_cookie 'msg', :value => str, :path => '/'
		else
			@str
		end
	end

	#provide the static file under module folder, like css, images, js.
	def _assets file_name, folder
		module_name = file_name.index('_') ? file_name.split('_').first : file_name.split('.').first
		file_type = file_name.index('.') ? file_name.split('.').last : ''
		path = settings.root + "/modules/#{module_name}/#{folder}/#{file_name}"

		if File.exist? path
			#file = File.new(path, "r") 
			send_file path, :type => file_type.to_sym

# 			if settings.cache_static_file
# 				#save the file to public/folder/file_name
# 				path = settings.root + "/public/#{folder}/#{file_name}"
# 				file = File.new(path, "r") 
# 			end
		else
			"No file found at module #{module_name}/#{file_type}/#{file_name}"
		end
	end

	#auto match the path 
	#== Arguments
	#@path, string, the url path
	#@data, array, the data collection includes the path, maybe
	#
	#== Returned
	# a matching path that is included in data, otherwise return origin path
	def _match_path path, data
		path_arr = []
		path_str = path
		path_arr = path.split "/" if path.index("/")

		until data.include?(path_str) or path_arr.empty?
			path_arr.pop
			path_str = path_arr.join("/")
		end

		path_str
	end

	#include the sub-template
	def _inc tpl_name
		slim tpl_name, :layout => false
	end

	#get two columns of database table as a key-value hash
	def _kv table, key, value
		res = {}
		DB[table].select(key, value).all.each do | row |
			res[row[key]] = row[value]
		end
		res
	end

	#load the template, and set the layout automatically
	def _tpl tpl_name
		module_name = request.path.split("/")[1]
		if Slayout.include? module_name
			slim tpl_name, :layout => "#{module_name}_layout".to_sym
		else
			slim tpl_name
		end
	end

	#return a random string with the size given
	def _random_string size = 12
		charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
		(0...size).map{ charset.to_a[rand(charset.size)]}.join
	end

	def _vars key = '', val = ''
		#set var
		if key != '' and val != ''
			ds = DB[:_vars].filter(:skey => key.to_s)
			if ds.count == 0
				DB[:_vars].insert(:skey => key.to_s, :sval => val.to_s, :changed => Time.now, :uid => _user[:uid])
			else
				ds.update(:sval => val, :changed => Time.now, :uid => _user[:uid])
			end

		#get var
		else
			sval = DB[:_vars].filter(:skey => key.to_s).get(:sval)
			sval = sval.index(',') ? sval.to_s.split(',') : sval.to_s
		end
	end

end
