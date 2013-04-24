# please don't modify the file unless you know what are you doing.
require 'seimtra/sbase'
include Seimtra

require './environment'

templates = []
applications = []

if DB_connect == "closed"
	puts "The datebase connection is closed."
	exit
else
	# load the module info
	M = DB[:_mods].all
end

if M.empty?
	puts "The loading module cannot be empty."
	exit
end

Slayout = []
M.each do | row |
	if row[:status] == 1
		#preprocess the templates loaded item
		templates << settings.root + "/modules/#{row[:name]}/#{Sbase::Folders[:tpl]}"

		#preprocess the applications loaded routors
		applications += Dir[settings.root + "/modules/#{row[:name]}/#{Sbase::Folders[:app]}/*.rb"]

		Slayout << row[:name] if File.exist? "#{settings.root}/modules/#{row[:name]}/#{Sbase::Folders[:tpl]}/#{row[:name]}_layout.slim"
	end
end

set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

#load the template language
class L
	@@options = {}
	class << self
		def [] key
			@@options.include?(key) ? @@options[key] : key.to_s
		end

		def []= key, val
			@@options[key.to_sym] = val
		end
	end
end
DB[:_lang].all.each do | row |
	L[row[:label]] = row[:content]
end

applications.each do | route |
	require route
end

#set the default page
get '/' do
#  	pass if request.path_info == '/'
	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
end
