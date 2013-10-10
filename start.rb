# please don't modify the file unless you know what are you doing.
require 'seimtra/sbase'
include Seimtra
require 'seimtra/sfile'
require './environment'

Sconfig 	= Sfile.read 'Seimfile'
templates 	= []
applications = []
Slayout 	= []
Svalid 		= {}
Sdata 		= {}

if DB_connect == "closed"
	puts "The datebase connection is closed."
	exit
else
	# load the module info
	M = DB[:_mods].order(:order).all
end

if M.empty?
	puts "All modules is closed."
	exit
end

#marks the file path that would be loaded soon
M.each do | row |
	#status 1 is opend
	if row[:status] == 1
		#view file
		templates << settings.root + "/modules/#{row[:name]}/#{Sbase::Folders[:tpl]}"

		#logic file
		applications += Dir[settings.root + "/modules/#{row[:name]}/#{Sbase::Folders[:app]}/*.rb"]

		#data file
		path = settings.root + "/modules/#{row[:name]}/#{Sbase::Folders[:store]}/data.rb"
		applications << path if File.exist? path

		#test file
		if Sconfig[:status] == 'test' or Sconfig[:status] == 'development'
			path = settings.root + "/modules/#{row[:name]}/#{Sconfig[:status]}"
			if File.exist? path
				applications += Dir["#{path}/*.rb"]
			end
		end

		#layout file
		Slayout << row[:name] if File.exist? "#{settings.root}/modules/#{row[:name]}/#{Sbase::Folders[:tpl]}/#{row[:name]}_layout.slim"
	end
end

#set the custom template
set :views, templates
helpers do
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end
end

#store block of data and valid
module Sinatra
	class Application < Base
		def self.data name = '', &block
			(Sdata[name] ||= []) << block
		end
		def self.valid name = '', &block
			(Svalid[name] ||= []) << block
		end
	end

	module Delegator
		delegate :data, :valid
	end
end

#caches language statement
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
DB[:_lang].each do | row |
	L[row[:label]] = row[:content]
end

#loads the files that would be run
applications.each do | route |
	require route
end

helpers do
	include Helpers
end
