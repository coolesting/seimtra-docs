class Seimtra_system

	def preprocess_user data
		require "digest/sha1"
		data[:pawd] 	= Digest::SHA1.hexdigest(data[:pawd] + data[:salt])
		data[:created] 	= Time.now
		data[:changed] 	= Time.now
		data
	end

end
