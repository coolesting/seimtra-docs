helpers do

	# == get the menu by the tag
	# @tag, string
	#
	# == returned value
	# data = [
	#	{:name => 'name', :link => 'link'},
	#	{:name => 'name', :link => 'link', :focus => true},
	#	{:name => 'name', :link => 'link', :sub_menu => [{:name => 'name', :link => 'link'},{},{}]},
	# ]
	def _menu tag

		ds = DB[:_menu].filter(:tid => _tags(tag)).order(:order)

		arr_by_preid	= {}
		arr_by_mid		= {}

		ds.each do | row |
			arr_by_mid[row[:mid]] = row
			arr_by_preid[row[:preid]] = [] unless arr_by_preid.has_key? row[:preid]
			arr_by_preid[row[:preid]] << row[:mid] 
		end

		data = []
		arr_by_preid[0].each do | mid |
			menu1 = {}
			menu1[:name] = arr_by_mid[mid][:name]
			menu1[:link] = arr_by_mid[mid][:link]
			if request.path == arr_by_mid[mid][:link]
				menu1[:focus] = true 
				@title = L[arr_by_mid[mid][:description].to_sym]
			end

			#has sub menu
			if arr_by_preid.has_key? mid
				menu1[:sub_menu] = []
				arr_by_preid[mid].each do | num |
					menu2 = {}
					menu2[:name] = arr_by_mid[num][:name]
					menu2[:link] = arr_by_mid[num][:link]
					if request.path == arr_by_mid[num][:link]
						menu1[:focus] = true 
						menu2[:focus] = true 
						@title = L[arr_by_mid[num][:description].to_sym]
					end
					menu1[:sub_menu] << menu2
				end
			end
			data << menu1
		end

		data

	end

end
