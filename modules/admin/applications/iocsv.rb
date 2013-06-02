get '/admin/iocsv' do
	@encoding = _var(:encoding) != "" ? _var(:encoding) : settings.default_encoding
	_tpl :admin_iocsv
end

#export
get '/admin/iocsv/export' do
	@encoding = _var(:encoding) != "" ? _var(:encoding) : settings.default_encoding
	table_name = params[:table_name] ? params[:table_name].to_sym : ''
	if DB.tables.include?(table_name)
		require 'csv'
		ds = DB[table_name]
		csv_file = CSV.generate do | csv |
			csv << DB[table_name].columns!
			csv << []
			ds.each do | row |
				csv << row.values
			end
		end

		if params.include?(:encoding) and params[:encoding] != settings.default_encoding
			require 'iconv'
			csv_file = Iconv.iconv(params[:encoding], "UTF-8", csv_file)
		end

   		attachment "#{table_name}.csv"
		csv_file
	else
		redirect back
	end
end

#inport
post '/admin/iocsv/inport' do
	if params[:inport] and params[:inport][:tempfile] and params[:inport][:filename]
		table		= params[:inport][:filename].split('.').first.to_sym
		contents 	= []
		require 'csv'

		#encoding
		if params.include?(:encoding) and params[:encoding] != settings.default_encoding
 			require 'iconv'
  			file_content = Iconv.iconv("UTF-8", params[:encoding], params[:inport][:tempfile].read)
		else
			file_content = params[:inport][:tempfile].read
		end

		CSV.parse(file_content) do | row |
			contents << row
		end

		#csv header
		columns = contents.shift
		columns_real = DB[table].columns

		#csv body
		contents.shift

		contents.each do | row |
			data = {}
			row.each_index do | i |
				if columns_real.include? columns[i].to_sym
					data[columns[i].to_sym] = row[i]
				end
			end
			DB[table].insert(data)
		end

		_msg L[:'upload complete']
	end

	redirect back
end
