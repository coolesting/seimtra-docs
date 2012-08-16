class Seimtra_system

	def preprocess_user data
		require "digest/sha1"
		data.each do | row |
			row[:pawd] 		= Digest::SHA1.hexdigest(row[:pawd] + row[:salt])
			row[:created] 	= Time.now
			row[:changed] 	= Time.now
		end
		data
	end

end
