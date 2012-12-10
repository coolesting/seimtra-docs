
get '/admin/editor' do
	sys_tpl :default
end

helpers do
	def editor_init_parser
		require 'redcarpet'
		@markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
	end

	def editor_m2h str
		@markdown.render str
	end
end
