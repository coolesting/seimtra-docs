helpers do

	#get the body by id, otherwise is blank string
	def _docs id
		res = DB[:_docs].filter(:doid => id).get(:body)
		res = '' unless res
		res
	end

	def _docs_add name, content, tag = nil
		DB[:_docs].insert(:name => name, :body => content, :tid => _tag(tag), :uid => _user[:uid], :created => Time.now)
	end

end

get '/_doc/:id' do
	if res = DB[:_docs].filter(:doid => params[:id].to_i).get(:body)
		res
	else
		L[:'No document found']
	end
end
