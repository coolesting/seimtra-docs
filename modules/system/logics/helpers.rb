module Helpers

	#return path
	def _url path, options = {}
		str = path
		unless options.empty?
			str += '?'
			options.each do | k, v |
				str = str + k.to_s + '=' + v.to_s + '&'
			end
		end
		str
	end

	#return path, with @qs
	def _url2 path, options = {}
		str = path
		qs = {}
		qs = qs.merge(@qs) unless @qs.empty?
		qs = qs.merge(options) unless options.empty?
		unless qs.empty?
			str += '?'
			qs.each do | k, v |
				str = str + k.to_s + '=' + v.to_s + '&'
			end
		end
		str
	end

	#throw out the message, and redirect back
	def _throw str
		response.set_cookie 'msg', :value => str, :path => '/'
		redirect back
	end

	#set the message if get a parameter, otherwise returns the @str value
	def _msg str = ''
		unless str == ''
			@msg = str
			response.set_cookie 'msg', :value => str, :path => '/'
		else
			@str
		end
	end

	#provide the static file under module folder, like css, images, js.
# 	def _assets file_name, folder
# 		module_name = file_name.index('_') ? file_name.split('_').first : file_name.split('.').first
# 		file_type = file_name.index('.') ? file_name.split('.').last : ''
# 		path = settings.root + "/modules/#{module_name}/#{folder}/#{file_name}"
# 
# 		if File.exist? path
# 			#file = File.new(path, "r") 
# 			send_file path, :type => file_type.to_sym
# 
# # 			if settings.cache_static_file
# # 				#save the file to public/folder/file_name
# # 				path = settings.root + "/public/#{folder}/#{file_name}"
# # 				file = File.new(path, "r") 
# # 			end
# 		else
# 			"No file found at module #{module_name}/#{file_type}/#{file_name}"
# 		end
# 	end

	#auto match the path 
	#== Arguments
	#@path, string, the url path
	#@data, array, the data collection includes the path, maybe
	#
	#== Returned
	# a matching path that is included in data, otherwise return origin path
	def _match_path path, data
		path_arr = []
		path_str = path
		path_arr = path.split "/" if path.index("/")

		until data.include?(path_str) or path_arr.empty?
			path_arr.pop
			path_str = path_arr.join("/")
		end

		path_str
	end

	#include the sub-template
	def _inc tpl_name
		slim tpl_name, :layout => false
	end

	#get two columns of database table as a key-value hash
	def _kv table, key, value
		name = "#{table}-#{key}-#{value}".to_sym
		unless @cache[:kv].has_key? name
			@cache[:kv][name] = DB[table].to_hash(key, value)
		end
		@cache[:kv][name]
	end

	#load the template, and set the layout automatically
	def _tpl tpl_name, layout = :layout
		if layout == nil
			slim tpl_name, :layout => false
		#default layout
		elsif layout == :layout
			module_name = request.path.split("/")[1]
			layout = "#{module_name}_layout".to_sym if Slayout.include? module_name
			slim tpl_name, :layout => layout
		else
			slim tpl_name, :layout => layout
		end
	end

	#return a random string with the size given
	def _random_string size = 12
		charset = ('a'..'z').to_a + ('0'..'9').to_a + ('A'..'Z').to_a
		(0...size).map{ charset.to_a[rand(charset.size)]}.join
	end

	#return a string
	def _var key, tag = nil
		DB[:_vars].filter(:skey => key.to_s, :tid => _tag(tag)).get(:sval)
	end

	#return an array, split by ","
	def _var2 key = '', tag = nil
		res = []
		ds = DB[:_vars].filter(:skey => key.to_s, :tid => _tag(tag))
		unless ds.empty?
			sval = ds.get(:sval)
			if sval.index(',')
				res = sval.to_s.split(',')
			else
				res << sval.to_s
			end
		end
		res
	end

	#save the variable
	def _var_set key, val, tag = nil
		ds = DB[:_vars].filter(:skey => key.to_s)
		if ds.count == 0
			#insert the variable, if that is not existing
			DB[:_vars].insert(:skey => key.to_s, :sval => val.to_s, :changed => Time.now, :tid => _tag(tag))
		else
			ds.update(:sval => val, :changed => Time.now, :tid => _tag(tag))
		end
	end

	def _valid name = ''
		Svalid[name].map { |b| instance_eval(&b) } if Svalid[name]
	end

	#return the data of block by name
	#
	#== Arguments
	#name, data name
	#reval, returned mode, include :all, :nopk, :getpk, :kv
	#
	#all mode, the hash below defines the base data format
	#{
	#	:value 	=>	'', #required
	#	:type	=>	'',
	#	:form	=>	'',
	#}
	#
	#

	def _data name = '', reval = :all
		res = {}
		if Sdata[name]
			res2 = Sdata[name].map { |b| instance_eval(&b) }.inject(:merge)
			unless res2.empty?

				#format the data
				res2.each do | k, v |
					#value
					res[k] = v.class.to_s == 'Hash' ? v : {:value => v}
					unless res[k].has_key? :value
						res[k][:value] = 1
					end

					#type of db field
					unless res[k].has_key? :type
						if res[k][:value].class.to_s == 'Fixnum'
							res[k][:type] = :integer
						else
							if k == :created or k == :changed
								res[k][:type] = :datetime
							else
								res[k][:type] = :string
							end
						end
					end

					#form
					unless res[k].has_key? :form
						if res[k][:type] == :integer
							res[k][:form] = :number
						elsif res[k][:type] == :text
							res[k][:form] = :textarea
						else
							res[k][:form] = :text
						end

						#select
						res[k][:form] = :select if res[k].has_key? :assoc_table
					end
				end

				#return data by reval
				#by default, the first one is primary key
				if reval == :getpk
					return res2.first[0]

				#return a key-val hash without primary key
				elsif reval == :nopk
					res3 = {}
					res.each do | k, v |
						res3[k] = v[:value] unless v.has_key? :pk
					end
					return res3

				#return a key-val hash
				elsif reval	== :kv
					res3 = {}
					res.each do | k, v |
						res3[k] = v[:value]
					end
					return res3
				end

 			end
		end
		res
	end

end

