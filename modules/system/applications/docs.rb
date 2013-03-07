helpers do

	#get the body by id, otherwise is blank string
	def _docs id
		result = DB[:_docs].filter(:doid => id).get(:body)
		result = '' unless result
		result
	end

	def _docs_add name, content, type = 'default'
		DB[:_docs].insert(:name => name, :body => content, :tid => _tags(type), :uid => _user[:uid], :created => Time.now)
	end

end

get '/_doc/:id' do
	if res = DB[:_docs].filter(:doid => params[:id].to_i).get(:body)
		res
	else
		'No document found'
	end
end
