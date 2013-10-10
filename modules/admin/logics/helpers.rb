module Helpers

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

	#init variable @t by specifying name
	def _init_t name
		@t[:tpl] 		||= :_default
		@t[:fields] 	||= _data(name, :nopk).keys
		@t[:layout] 	||= :layout
		@t[:editby] 	||= {}
		@t[:viewby]		||= {}
		@t[:viewcss]	||= _public('/css/table-1.css')
		@t[:formcss]	||= ''
		@t[:js]			||= []
		@t[:btnback] 	||= :enable
		@t[:btnadd]		||= :enable
		@t[:btnedit]	||= :enable
		@t[:btndel]		||= :enable
		@t[:repath] 	||= request.path

		if @t.include?(:search) and @t[:search] == :enable
			@t[:search] = _data(name, :nopk).keys
		end
	end

	#merge the options to @t
	def _prepare options = {}
		@t.merge!(options) unless options.empty? 
	end

	#form view
	def _form name
		_init_t name
		pk = _data(name, :getpk)
		@data = _data(name)

		#default condition of edit
		@t[:editby][pk] = @qs[pk].to_i if @qs.include?(pk)

		#get data
		data = nil
		unless @t[:editby].empty?
			ds = DB[name].filter(@t[:editby])
			data = ds.first unless ds.empty?
		end

		data = _data(name, :kv) unless data
		_set_fields @t[:fields], data

		@t[:title] 	= L[:'edit the '] + L[name]
		@t[:tpl] 	= :_form if @t[:tpl] == :_default
		_tpl @t[:tpl], @t[:layout]
	end

	#normal view
	def _view name
		_init_t name
		pk = _data(name, :getpk)
		@data = _data(name)

		if @qs[:sw] and @qs[:sc]
			sw = @qs[:sw].to_sym
			sc = @qs[:sc]
			if @data[sw].has_key? :assoc_table
				assoc_data = _kv @data[sw][:assoc_table], @data[sw][:assoc_name], @data[sw][:assoc_field]
				sc = assoc_data[sc]
			end
			@t[:viewby][sw] = sc
		end
		ds = DB[name].filter(@t[:viewby])

		#order
		if @qs[:order]
			ds = ds.order(@qs[:order].to_sym)
		else
			ds = ds.reverse_order(pk)
		end

		Sequel.extension :pagination
		@ds = ds.paginate(@page_curr, @page_size, ds.count)
		@page_count = @ds.page_count

		@t[:title] 	= L[name]
		@t[:tpl] 	= :_view if @t[:tpl] == :_default
		_tpl @t[:tpl], @t[:layout]
	end

	#admin view
	def _admin name
		#edit content
		if @qs[:opt] == 'form'
			_form name

		#remove record
		elsif @qs[:opt] == 'rm'
			_rm name

		#display view
		else
			@t[:tpl] = :_admin
			_view name
		end
	end

	#submit data
	def _submit name
		_init_t name
		pk = _data(name, :getpk)

		#default condition of edit
		@t[:editby][pk] = @qs[pk].to_i if @qs.include?(pk)

		#get data
		data = nil
		unless @t[:editby].empty?
			ds = DB[name].filter(@t[:editby])
			data = ds.first unless ds.empty?
		end

		unless data
			data = _data(name, :nopk)
			_set_fields @t[:fields], data, true
			opt = :insert
		else
			_set_fields @t[:fields], data
			opt = :update
		end

		_valid name

		#insert
		if opt == :insert
			DB[name].insert(@f)
		#update
		else
			DB[name].filter(@t[:editby]).update(@f)
		end
		redirect @t[:repath] unless @t[:repath] == nil
	end

	#remove record
	def _rm name
		pk = _data(name, :getpk)
		@t[:rmby] 		||= {}
		@t[:rmby][pk] 	= @qs[pk].to_i if @qs.include?(pk)

		unless @t[:rmby].empty?
			_msg L[:'delete the record by id '] + @t[:rmby][pk].to_s
			DB[name].filter(@t[:rmby]).delete
		end
		redirect back
	end

end
