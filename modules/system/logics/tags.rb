module Helpers

	#retunr the tag id by name
	#if the name is not existing, create it.
	def _tag name = nil
		return 1 if name == nil
		name = name.to_s
		ds = DB[:_tags].filter(:name => name)
		if ds.empty?
			DB[:_tags].insert(:name => name) 
			DB[:_tags].filter(:name => name).get(:tid)
		else
			ds.get(:tid)
		end
	end

end
