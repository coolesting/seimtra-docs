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
		redirect("/admin/errors/#{str}") 	
	end

	def menu_focus path, des = nil
		reval = ""
		if request.path.split("/")[2] == path.split("/")[2]
			reval = "focus"
		end
		reval
	end

	def sys_opt *argv
		set :sys_opt, argv
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

end
