class Seimtra_system
	
	def preprocess__menu data
		#prevoicu name
		if data.include? :menu_name
			ds = DB[:_menu].filter(:name => data[:menu_name].to_s)
			data[:preid] = ds.get(:mid) unless ds.empty?
			data.delete :menu_name
		end

		#tag id
		data = preprocess___tags(data)
	end

	def preprocess__mods data
		data = preprocess___tags(data)
	end

	def preprocess__docs data
		data = preprocess___tags(data)
	end

	def preprocess__task data
		data = preprocess___tags(data)
	end

	def preprocess__user data
		require "digest/sha1"
		data[:pawd] = Digest::SHA1.hexdigest(data[:pawd] + data[:salt])
		data
	end

	#change the type or tag field to tag id
	#return the data 
	def preprocess___tags data
		name = 'general' 
		tags_alaise = [:tag, :type]
		tags_alaise.each do | item |
			name = data.delete(item) if data.include?(item)
		end
		if DB[:_tags].filter(:name => name).empty?
			DB[:_tags].insert(:name => name) 
		end
		data[:tid] = DB[:_tags].filter(:name => name).get(:tid)
		data
	end

end
