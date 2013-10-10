require './start'

#api class
class Sapi

	# A interface class for Sequel ORM
	attr_accessor :msg, :error, :connect

	def initialize
		@msg 		= ''
		@error 		= false
		@connect 	= DB_connect

# 		epath 	= File.expand_path(path)
# 		if File.exist?(epath)
# 			require epath
# 		else
# 			@error 	= true
# 			@msg	= 'No such the file ' + epath
# 		end
	end

	#@name symbol
	def check_column name
		columns = get_columns
		columns.include?(name) ? true : false
	end

	def get_tables
		DB.tables
	end

	def get_scheme
		DB.class.adapter_scheme.to_s
	end

	def get_schema table
		DB.schema table
	end

	##
	# table, string
	def get_columns table = nil
		if table == nil
			argv = []
			get_tables.each do | table |
				argv += DB[table.to_sym].columns!
			end
			argv
		else
			DB[table.to_sym].columns!
		end
	end

	def dump_schema table
		Sequel.extension :schema_dumper
		DB.dump_table_schema(table)
	end

	def dump_schema_migration
		Sequel.extension :schema_dumper
		DB.dump_schema_migration
	end

	def run path, argv = {}
		Sequel.extension :migration
		Sequel::Migrator.run DB, path, argv
	end

	def insert table, options = {}
		unless options.empty?
			DB[table].insert(options)
		end
	end

	def select table
		DB.tables.include?(table) ? DB[table.to_sym] : nil
	end

	# == autocomplete
	# autocomplete field of database
	# 
	# == input
	# @name string, the table name
	# @argv array, 	the fields
	#
	# == output
	# the field be passed like this ['title', 'body']
	# output like this ['aid:primary_key', 'title', 'body', 'changed:datetime']
	def autocomplete name, argv
		item = [:pk, :changed]
		scfg = Sfile.read "#{Dir.pwd}/#{Sbase::File_config[:seimfile]}"
		if scfg.include? :autocomplete
			if scfg[:autocomplete].index ','
				item = []
				scfg[:autocomplete].split(',').each do | i |
					item << i.to_sym
				end
			else
				item = [scfg[:autocomplete].to_sym]
			end
		end

		#match a id
		if item.include? :pk
			i = 1
			while i > 0 
				id 	= name[0, i] + 'id'
				i 	= check_column(id.to_sym) ? (i + 1) : 0
			end
			argv.unshift("#{id}:primary_key")
		end

		#match time field
		if item.include? :changed
			argv << 'changed:datetime'
		end
		if item.include? :created
			argv << 'created:datetime'
		end
		argv
	end

	# == arrange_fields
	# arrange the fields with specifying format
	# 
	# == Arguments
	# @data array, the details as following
	# @auto boolen, 
	#
	# ['table_name', 'field1', 'field2', 'field3']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:string:null=false']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:assoc=table.field_name']
	# ['table_name', 'field1:primary_id', 'field2:string', 'field3:assoc=table.field_name:html=select']
	# ['rename', 'old_table', 'new_table]
	# ['drop', 'field1', 'field2', 'field3']
	# ['alter', 'table_name', 'field1', 'field2', 'field3']
	#
	# == Returned
	# it is a hash value, the options as the following
	# :operator, symbol ---- :create, :alter, :drop, :rename
	# :table, 	string 	---- table name
	# :fields,	array 	---- [field1, field2, field3]
	# :types,	hash	---- {field1 => type_name, field2 => type_name}
	# :htmls,	hash	---- {field1 => html_type, field2 => html_type}
	# :others,	hash	---- {field1 => {attr => val}, field2 => {attr1 => val1, attr2 => val2}}
	# :assoc,	hash	---- {field1 => [table, field1, assoc_field], field2 => [table, field2, assoc_field]}

	def arrange_fields data, auto = false
		res = {}

		#operator
		operators = [:alter, :rename, :drop]
		res[:operator] = operators.include?(data[0].to_sym) ? data.shift.to_sym : :create

		#table
		if res[:table] == :rename or res[:table] == :drop
			res[:table] = data.join "_"
		else
			res[:table] = data.shift
		end

		res[:htmls] 	= {}
		res[:types] 	= {}
		res[:fields] 	= []
		res[:others] 	= {}
		res[:assoc] 	= {}


		if data.length > 0

			#auto the fields
			data = autocomplete(res[:table], data) if auto == true
			data.each do | item |
				if item.include?(":")
					arr = item.split(":")

					#field name
					field = arr.shift
					res[:fields] << field

					#field type
					if Sbase::Field_type.has_key? arr[0].to_sym
						res[:types][field] = Sbase::Field_type[arr.shift.to_sym]
					else
						res[:types][field] = match_field_type field
					end

					res[:htmls][field] = res[:types][field]

					#other attributes and assoc table-field
					if arr.length > 0
						arr.each do | a |
							if a.include? "="
								key, val = a.split "="
								key = key.to_sym

								if key == :assoc
									#the associated attribute format likes this, field:assoc=table.field
									res[:assoc][field] = {} unless res[:assoc].include? field
									if val.include? "."
										table, assoc_field = val.split "."
										res[:assoc][field] = [table, field, assoc_field]
									end
									res[:htmls][field] = "select"
									res[:types][field] = "integer"
								elsif key == :html or key == :htmls
									res[:htmls][field] = val
									res[:types][field] = "string" if val == "checkbox"
								else
									res[:others][field] = {} unless res[:others].include? field
									res[:others][field][key] = val
								end
								
							end
						end
					end
				else
					res[:fields] << item
					res[:htmls][item] = "string"
					res[:types][item] = match_field_type item
				end
			end
		end
		
		res
	end

	#judge the field type, automatically 
	def match_field_type field
		field = field.to_s
		len   = field.length
		if field[len-2] == 'i' and field[len-1] == 'd'
			'integer'
		elsif field == 'order'
			'integer'
		elsif field == 'level'
			'integer'
		elsif field == 'changed'
			'datetime'
		elsif field == 'created'
			'datetime'
		else
			'string'
		end
	end

	def generate_migration data
		main_key	= Sbase::Main_key
		operator 	= data[:operator]
		table		= data[:table]
		fields		= data[:fields]
		types		= data[:types]

		content = "Sequel.migration do\n"
		content << "\tchange do\n"

		if operator == :drop or operator == :rename
			content << "\t\t#{operator}_table "
			i = 0
			fields.each do | f |
				content << ", " if i > 0
				content << ":#{f}"
				i = i + 1
			end
			content << "\n"

		elsif operator == :create
			content << "\t\t#{operator}_table(:#{table}) do\n"
			fields.each do | item |
				content << "\t\t\t"
				if main_key.include? types[item].to_sym
					content << "#{types[item]} :#{item}"
				else
					content << "#{types[item].capitalize} :#{item}"
				end
				content << "\n"
			end
			content << "\t\tend\n"

		elsif operator == :alter
			content << "\t\t#{operator}_table(:#{table}) do\n"
			content << "\t\t\t#{fields.shift} :"
			content << fields.join(", :")
			content << "\n"
			content << "\t\tend\n"
		end

		content << "\tend\n"
		content << "end\n"
		content
	end

	# == check_module
	# check the local file module whether existing in db
	#
	# == output
	# return the local module that has not been installed to database, otherwise is null 
	def check_module module_names
		#get all of module if nothing be specified to installing
		install_modules = []
		local_modules	= []
		db_modules		= []

		Dir["modules/*/#{Sbase::File_generated[:info]}"].each do | item |
			local_modules << item.split("/")[1]
		end

		if select(:module)
			select(:module).all.each do | row |
				db_modules << row[:name] unless row[:name] == "" or row[:name] == nil
			end
		end

		install_modules = module_names.empty? ? local_modules : module_names

		return_modules = []
		db_modules.each do | item |
			return_modules << item unless install_modules.include? item
		end

		return_modules = local_modules if db_modules.empty?
		return_modules.empty? ? nil : return_modules
	end

	#add module to db
	def add_module install_modules

		scfg = Sfile.read "#{Dir.pwd}/#{Sbase::File_config[:seimfile]}"
		default_lang = scfg.include?(:lang) ? scfg[:lang] : 'en'

		#first of all, load the installation library
		module_installs = get_module
		unless install_modules.class.to_s == "Array"
			arr = []
			arr << install_modules
			install_modules = arr
		end

		#load all of module installer
		install_modules.each do | m |
			module_installs << m unless module_installs.include? m
		end

		module_installs << 'system' unless module_installs.include? 'system'

		module_installs.each do | mod |
			load_installer mod
		end

		#second, scan the file info of installation folder to database
		install_modules.each do | name |
			file = Dir.pwd + "/modules/#{name}/#{Sbase::Folders[:install]}/_tags"
			if File.exist? file
				write_sfile '_tags', file
			end
		end

		install_modules.each do | name |
			file = Dir.pwd + "/modules/#{name}/#{Sbase::Folders[:install]}/_mods"
			if File.exist? file
				write_sfile '_mods', file
			end
		end

		install_modules.each do | name |
			@module_name = name
			Dir["modules/#{name}/#{Sbase::Folders[:install]}/*"].each do | file |
				table = file.split("/").last
				unless table == '_mods' or table == '_tags'
					write_sfile table, file
				end
			end

			#scanning the language folder
			path = Dir.pwd + "modules/#{name}/#{Sbase::Folders_others[:lang]}/#{default_lang}"
			if File.exist? path
				result = Sfile.read path
 				result.each do | label, content |
					fields = {:label => label.to_s, :uid => 1}
					if DB[:_lang].filter(fields).count == 0
						fields[:content] = content
 						DB[:_lang].insert(fields)
					else
						DB[:_lang].filter(fields).update(:content => content)
					end
 				end
			end
		end

	end

	# write the *.sfile of install dir to db
	#
	# @table, table name
	# @file, sfile path
	def write_sfile table, file
		result = Sfile.read file

		#insert data
		unless result == nil
			if result.class.to_s == "Hash"
				arr = []
				arr << result
				result = arr
			end

			result.each do | row |
				if Sapi.public_method_defined? "preprocess_#{table}".to_sym
					eval "row = preprocess_#{table}(#{row})"
				end
				write_to_db table, row
			end
		end
	end

	def load_installer name
		path = Dir.pwd + "/modules/#{name}/#{Sbase::File_installer[0]}"
		if File.exist? path
			require path 
		end
	end

	# == write_to_db
	# write a sfile to db with row by row
	#
	# == Arguments
	# table, string, a table name
	# result, hash, table field data
	def write_to_db table, row
		table	= table.to_sym
		tables	= get_tables
		
		if tables.include? table
			table_fields = DB[table].columns!

			fields = {}
			if row.class.to_s == "Hash"
				row.each do | key, val |
					if table_fields.include? key.to_sym
						fields[key.to_sym] = val
					end
				end

				return if fields.empty?

				#do not insert if the data is exsiting
				#delete the time
				fields.delete :changed if fields.include? :changed
				if DB[table].filter(fields).count == 0
					fields[:changed] = Time.now if table_fields.include? :changed 
					insert table, fields
				end
			end
		end
	end

	# == get_module
	# get all of modules that have been installed to database
	def get_module
		modules = []
		DB[:_mods].each do | row |
			modules << row[:name]
		end
		modules
	end

	def get_route name
		env = {'PATH_INFO' => name, 'REQUEST_METHOD' => 'GET', 'rack.input' => ''}
		_, _, body = Sinatra::Application.call env
		res = ''
		body.each do | b |
			res = b
		end
		res
	end

	#compare the data with db schema
	def data_compare
		#current data from file
		env = {'PATH_INFO' => '/_api/data', 'REQUEST_METHOD' => 'GET', 'rack.input' => ''}
		_, _, body = Sinatra::Application.call env
		cur_data = {}
		body.each do | k, v |
			cur_data[k] = v
		end

		#compare the current data with db data schema
		create_table = {}
		alter_column = {}
		drop_column = {}
		add_column = {}
		db_tables = DB.tables

		cur_data.each do | table, columns |
			#compare two table, and save the changes if the schema has been alter in file
			if db_tables.include? table
				origin_columns = Hash[*DB.schema(table).flatten]

				#compare the column that has been changed
				columns.each do | k, v |
					if origin_columns.has_key? k
						#compare the field type with db
						if origin_columns[k][:type] != v[:type]
							alter_column[table] ||= {}
							alter_column[table][k] = v
						end
						origin_columns.delete k

					#no column, create it
					else
						add_column[table] ||= {}
						add_column[table][k] = v
					end

				end

				#delete the column that not exists in new schema of db
				unless origin_columns.empty?
					drop_column[table] ||= {}
					drop_column[table] = origin_columns.keys
				end

				db_tables.delete table
			#no table, create it
			else
				create_table[table] = columns
			end
		end

		db_tables.delete :schema_info
		res = {:create => create_table, :alter => [add_column, alter_column, drop_column], :drop => db_tables}
	end

	def generate_migration2 data
		main_key	= Sbase::Main_key

		content = "Sequel.migration do\n"
		content << "\tchange do\n"

		data.each do | operater, panel |
			unless panel.empty?

				#drop table
				if operator == :drop
					content << "\t\t#{operator}_table :#{panel.join(', :')} \n"

				#rename table
				elsif operator == :rename
					panel.each do | old_table, new_table |
						content << "\t\t#{operator}_table :#{old_table}, :#{new_table} \n"
					end

				#create table
				elsif operator == :create
					panel.each do | table, row |
						content << "\t\t#{operator}_table(:#{table}) do\n"
							row.each do | col_name, col_item |
								content << "\t\t\t"
								#here, we are doing, currently.
								if main_key.include? row[col_name][:type].to_sym
									content << "#{types[item]} :#{col_name}"
								else
									content << "#{row[col_name][:type].capitalize} :#{col_name}"
								end
								content << "\n"
							end
						content << "\t\tend\n"
					end

				#alter table
				elsif operator == :alter
					panel.each do | table, row |
						content << "\t\t#{operator}_table(:#{table}) do\n"
						#content << "\t\t\t#{fields.shift} :"
						#content << fields.join(", :")
						content << "\n"
						content << "\t\tend\n"
					end
				end

			end
		end

		content << "\tend\n"
		content << "end\n"
		content
	end

end

get '/_api/data' do
	res = {}
	Sdata.keys.each do | k |
		res[k] = _data(k)
	end
	res
end

o = Sapi.new
puts o.data_compare

