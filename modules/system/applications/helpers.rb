helpers do
	
	def throw_error str
		redirect("/system/errors/#{str}") 	
	end

	def set_title str
		@title = str
	end

	def iset key, val, mid = 0
		dataset = DB[:setting].where(:skey => key.to_s, :mid => mid)
		if dataset[:sval]
			dataset.update(:sval => val, :changed => Time.now)
		else
			DB[:setting].insert(:skey => key.to_s, :sval => val.to_s, :mid => mid, :changed => Time.now)
		end
	end

	def iget key, mid = 0
		sval = DB[:setting].filter(:skey => key.to_s, :mid => mid).get(:sval)
		sval ? sval.to_s : ""
	end

	def menu_focus path, des = nil
		reval = ""
		if request.path.split("/")[2] == path.split("/")[2]
			reval = "focus"
# 			set(:msg, des) unless des == nil
		end
		reval
	end

	def opt_events *argv
		set :opt_events, argv
	end

	#provide the static file , like css, images, js.
	def static_file file_name, folder

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
