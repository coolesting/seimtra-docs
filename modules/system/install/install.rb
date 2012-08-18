class Seimtra_system
	
	def preprocess_menu data
		if data.include? :prename
			preid = DB[:menu].filter(:name => data[:prename].to_s).get(:mid)
			if preid.to_i
				data[:preid] = preid
				data.delete :prename
			end
		end
		data
	end

end
