class Seimtra_system

	def system_add_user data
		data.each do | row |
			require "digest/sha1"

			row[:pawd] 		= Digest::SHA1.hexdigest(row[:pawd] + row[:salt])
			row[:created] 	= Time.now
			row[:changed] 	= Time.now

			DB[:user].insert(row)
		end
	end

end
