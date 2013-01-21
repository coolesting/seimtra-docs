helpers do

	#retunr the tag id by name
	#if the name is not existing, create it.
	def _tags name
		name = name.to_s
		tid = DB[:_tags].filter(:name => name).get(:tid)
		unless tid
			DB[:_tags].insert(:name => name) 
			tid = DB[:_tags].filter(:name => name).get(:tid)
		end
		tid
	end

end
