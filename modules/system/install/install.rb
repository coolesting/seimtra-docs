class Seimtra_system
	
	def preprocess__menu data
		#prevoiuc name
		if data.include? :menu_name
			ds = DB[:_menu].filter(:name => data[:menu_name].to_s)
			data[:preid] = ds.get(:mid) unless ds.empty?
			data.delete :menu_name
		end
		#tag name
		data[:type] = 'general' unless data.include? :type
		data
	end

# 	def preprocess__tags data
# 		if data.include?(:module_name)
# 			module_name = data.delete :module_name
# 		else
# 			module_name = @module_name
# 		end
# 		data[:mid] = DB[:_mods].filter(:name => module_name).get(:mid)
# 		data
# 	end

	def preprocess__user data
		require "digest/sha1"
		data[:pawd] = Digest::SHA1.hexdigest(data[:pawd] + data[:salt])
		data
	end


end
