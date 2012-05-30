get '/admin/links' do
	opt_events :add, :remove, :alter
	@title += ' the system links'
	@links = DB[:links]
	slim :links
end
