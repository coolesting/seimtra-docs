# please don't modify the file unless you know what are you doing.
require 'seimtra/sbase'
include Seimtra

require './environment'
require './lib'

language = []
templates = []
languages = []
applications = []

if settings.db_connect == "closed"
	puts "The datebase connection is closed."
	exit
else
	# load the module info
	M = DB[:module]
end

if M.empty?
	puts "The loading module cannot be empty."
	exit
end

Slayout = []
M.each do | row |
	if row[:opened] == "on"
		#preprocess the templates loaded item
		templates << settings.root + "/modules/#{row[:name]}/templates"

		#preprocess the applications loaded routors
		applications += Dir[settings.root + "/modules/#{row[:name]}/applications/*.rb"]

		language << row[:mid] unless language.include? row[:mid]

		Slayout << row[:name] if File.exist? "#{settings.root}/modules/#{row[:name]}/templates/#{row[:name]}_layout.slim"

	end
end

set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

#load the template language
language.each do | mid |
	languages += DB[:language].filter(:mid => mid).all
end

languages.each do | row |
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
