helpers do

	#get the body by name, otherwise is null string
	def _docs name
		result = DB[:_docs].filter(:name => name.to_s).get(:body)
		result = '' unless result
		result
	end

	def _docs_add name, content, type = 'default'
		DB[:_docs].insert(:name => name, :body => content, :tid => _tags(type), :uid => _user[:uid], :created => Time.now)
	end

end
