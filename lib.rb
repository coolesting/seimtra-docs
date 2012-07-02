#return a random string with the size given
def random_string size = 12
	charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
	(0...size).map{ charset.to_a[rand(charset.size)]}.join
end

def get_file file
	result = {}
	content = ''
	content << File.read(file) if File.exist? file
	if content.index("\n")
		content.split("\n").each do | line |
			unless line[0] == '"' and line.index("=")
				key,val = line.split("=")
				result[key] = val
			end
		end
	end
	result
end

class L
	@@options = {}

	class << self
		def [] key
			@@options.include?(key) ? @@options[key] : key.to_s
		end

		def []= key, val
			@@options[key.to_sym] = val
		end
	end
end
