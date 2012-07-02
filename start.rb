# please don't modify the file unless you know what are you doing.
require 'seimtra/base'
include Seimtra

require './environment'
require './lib'

#set the default page
get '/' do
	status, headers, body = call! env.merge("PATH_INFO" => settings.home_page)
end

templates = []
languages = ""
applications = []

#module info
M = {}

#get the info from local file
if settings.db_connect == "closed"
# 	Dir[settings.root + "/modules/*/" + Seimtra::Sbase::Files[:info]].each do | file |
# 		content = get_file file
# 		unless content.empty? and content.include?('name') and content.include?('open') and content['open'] == "on"
# 			M[content['name']] = content 
# 		end
# 	end
puts "The dasebase connect is closed."
exit

#enable the database
else
	modules = DB[:modules]
	modules.each do | row |
		M[row[:mid]] = row
	end
end

if M.empty?
	puts "The loading module cannot be empty."
	exit
end

M.each do | mid, row |
	if row[:opened] == "on"
		#preprocess the templates loaded item
		templates << settings.root + "/modules/#{row[:name]}/templates"

		#preprocess the applications loaded routors
		applications += Dir[settings.root + "/modules/#{row[:name]}/applications/*.rb"]

		#preprocess the language loaded packets
		language = row.include?('lang') ? row['lang'] : "en"
		path = settings.root + "/modules/#{row[:name]}/languages/#{language}.lang"
		languages << File.read(path) if File.exist?(path)
	end
end

set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

languages.split("\n").each do | line |
	if line.index("=")
		key, val = line.split("=", 2) 
		L[key] = val
	end
end

applications.each do | routor |
	require routor
end

