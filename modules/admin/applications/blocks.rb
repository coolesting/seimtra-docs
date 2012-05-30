get '/admin/blocks' do
	opt_events :add, :remove, :alter
	@title += ' the system blocks'
	@blocks = DB[:blocks]
	slim :blocks
end

get '/admin/blocks/new' do
	set :msg, 'Add a new block'
	slim :admin_block_new
end
