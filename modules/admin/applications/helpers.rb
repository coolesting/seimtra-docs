helpers do

	#set the field values
	#
	#== Arguments
	# fields, which field need to set , null is all
	# data,   default values of field
	# full,	  fill the @f with default values
	def _set_fields fields = [], data = {}, full = false
		fields 	= data.keys if fields.empty?
		@f = data if full == true

		fields.each do | k |
			if params[k]
				@f[k] = params[k]
			elsif @qs.include? k
				@f[k] = @qs[k]
			else
				@f[k] = data[k]
			end
		end
	end

	def _valid name = ''
		Svaild[name].map { |b| instance_eval(&b) } if Svaild[name]
	end

	#return the data by name
	#
	#== Arguments
	#name, data name
	#reval, returned value, include :normal
	def _data name = '', reval = :normal
		res = {}
		if Sdata[name]
			res2 = Sdata[name].map { |b| instance_eval(&b) }.inject(:merge)
			unless res2.empty?
 				res2.each do | k, v |

					if v.class == 'Hash'
						#do not return value :pk
 						if reval == :normal and v.has_key?(:pk)
 						else
							res[k] = v.include?([:value]) ? v[:value] : ''
 						end
					elsif v.class == 'Array'
						res[k] = v[0]
					else
						res[k] = v
					end

				end
 			end
		end
		res
	end

	#init variable @t
	def _init_t options = {}
		if options.empty? 
			@t[:tpl] 		||= :_default
			@t[:fields] 	||= []
			@t[:layout] 	||= :layout
			@t[:editby] 	||= {}
			@t[:viewby]		||= {}
			@t[:rmby] 		||= {}
			@t[:formcss] 	||= ''
			@t[:viewcss]	||= ''
			@t[:btnback] 	||= :enable
			@t[:btnadd]		||= :enable
		else
			@t.merge! options
		end
	end

end
