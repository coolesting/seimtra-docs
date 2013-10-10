
valid :_docs do
		
		if @f.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
		if @f.include?(:body)
			_throw(L[:'the field cannot be empty '] + L[:'body']) if @f[:body].strip.size < 1
		end
		
end

	def _lang_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:label)
			_throw(L[:'the field cannot be empty '] + L[:'label']) if @f[:label].strip.size < 1
		end
		
		if fields.include?(:content)
			_throw(L[:'the field cannot be empty '] + L[:'content']) if @f[:content].strip.size < 1
		end
		
		if fields.include?(:uid)
			#_throw(L[:'the field cannot be empty '] + L[:'uid']) if @f[:uid] != 0
		end
		
	end


	def _menu_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:preid)
			#_throw(L[:'the field cannot be empty '] + L[:'preid']) if @f[:preid] != 0
		end
		
		if fields.include?(:order)
			#_throw(L[:'the field cannot be empty '] + L[:'order']) if @f[:order] != 0
		end
		
		if fields.include?(:name)
			_throw(L[:'the field cannot be empty '] + L[:'name']) if @f[:name].strip.size < 1
		end
		
		if fields.include?(:link)
			_throw(L[:'the field cannot be empty '] + L[:'link']) if @f[:link].strip.size < 1
		end
		
		if fields.include?(:description)
			_throw(L[:'the field cannot be empty '] + L[:'description']) if @f[:description].strip.size < 1
		end
		
	end


	def _note_valid_fields fields = []
		fields = @f.keys if fields.empty?
		
		if fields.include?(:from_uid)
			#_throw(L[:'the field cannot be empty '] + L[:'from_uid']) if @f[:from_uid] != 0
		end
		
		if fields.include?(:to_uid)
			#_throw(L[:'the field cannot be empty '] + L[:'to_uid']) if @f[:to_uid] != 0
		end
		
		if fields.include?(:mark)
			_throw(L[:'the field cannot be empty '] + L[:'mark']) if @f[:mark].strip.size < 1
		end
		
		if fields.include?(:tid)
			field = _kv :_tags, :tid, :name
			_throw(L[:'the field does not exist '] + L[:'tid']) unless field.include? @f[:tid].to_i
		end
		
		if fields.include?(:content)
			_throw(L[:'the field cannot be empty '] + L[:'content']) if @f[:content].strip.size < 1
		end
		
		if fields.include?(:created)
			_throw(L[:'the field cannot be empty '] + L[:'created']) if @f[:created].strip.size < 1
		end
		
	end
