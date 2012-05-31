get '/admin/links' do
	opt_events :add, :remove, :alter
	@title += ' the system links'
	@links = DB[:links].order(:order).reverse
	slim :links
end
