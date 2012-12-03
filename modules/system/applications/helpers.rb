helpers do

	def sys_url path, options = {}
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

	def sys_json hash
	end

	def throw_error str
		response.set_cookie 'msg', :value => str, :path => '/'
		redirect back
	end

	def sys_msg str
		@msg = str
		response.set_cookie 'msg', :value => str, :path => '/'
	end

	#provide the static file , like css, images, js.
	def sys_file file_name, folder

		module_name = file_name.index('_') ? file_name.split('_').first : file_name.split('.').first
		file_type = file_name.index('.') ? file_name.split('.').last : ''
		path = settings.root + "/modules/#{module_name}/#{folder}/#{file_name}"

		if File.exist? path
			file = File.new(path, "r") 
			send_file path, :type => file_type.to_sym

			if settings.cache_static_file
				#save the file to public/folder/file_name
				path = settings.root + "/public/#{folder}/#{file_name}"
				file = File.new(path, "r") 
			end
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
	def sys_match_path path, data

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
	def sys_tpl tpl_name
		slim tpl_name, :layout => false
	end

	#get two columns of database table as a key-value hash
	def sys_kv table, key, value
		res = {}
		DB[table].select(key, value).all.each do | row |
			res[row[key]] = row[value]
		end
		res
	end

	def sys_slim tpl_name, sub_tpl = nil
		
		@sub_tpl = sub_tpl

		#set the layout automatically
		module_name = request.path.split("/")[1]
		if Slayout.include? module_name
			slim tpl_name, :layout => "#{module_name}_layout".to_sym
		else
			slim tpl_name
		end

	end

end
