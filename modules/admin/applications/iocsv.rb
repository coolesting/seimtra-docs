get '/admin/iocsv' do
	@encoding = _vars(:encoding) != "" ? _vars(:encoding) : settings.default_encoding
	_tpl :admin_iocsv
end

#export
get '/admin/iocsv/export' do

	@encoding = _vars(:encoding) != "" ? _vars(:encoding) : settings.default_encoding

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
		table	= params[:inport][:filename].split('.').first
		@content = []
		require 'csv'

		#encoding
		if params.include?(:encoding) and params[:encoding] != settings.default_encoding
 			require 'iconv'
  			file_content = Iconv.iconv("UTF-8", params[:encoding], params[:inport][:tempfile].read)
		else
			file_content = params[:inport][:tempfile].read
		end

		CSV.parse(file_content) do | row |
			@content << row
		end

		#csv header
		columns = @content.shift

		#csv body
		@content.shift

		@content.each do | row |
			data = {}
			columns.zip(row) { |a,b| data[a.to_sym] = b }
			DB[table.to_sym].insert(data)
		end

		_msg L[:'upload complete']
	end

	redirect back

end
