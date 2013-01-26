helpers do

	#retunr the tag id by name
	#if the name is not existing, create it.
	def _tags name
		name = name.to_s
		if DB[:_tags].filter(:name => name).empty?
			DB[:_tags].insert(:name => name) 
		end
		tid = DB[:_tags].filter(:name => name).get(:tid)
	end

end
