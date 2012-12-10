get '/admin/iocsv' do
	@encoding = sys_get(:encoding) != "" ? sys_get(:encoding) : settings.default_encoding
	sys_tpl :admin_iocsv
end

#get db table as csv file output
get '/admin/iocsv/export' do

	@encoding = sys_get(:encoding) != "" ? sys_get(:encoding) : settings.default_encoding

	if params[:export] and (DB.tables.include?(params[:export].to_sym))
		require 'csv'
		ds = DB[params[:export].to_sym]
		csv_file = CSV.generate do | csv |
			csv << DB[params[:export].to_sym].columns!
			csv << []
			ds.each do | row |
				csv << row.values
			end
		end

		if params.include?(:encoding) and params[:encoding] != settings.default_encoding
			require 'iconv'
			csv_file = Iconv.iconv(params[:encoding], "UTF-8", csv_file)
		end

   		attachment "#{params[:export]}.csv"
		csv_file
	else
		redirect back
	end

end

#upload file
post '/admin/iocsv/inport' do

	if params[:inport] and params[:inport][:tempfile] and params[:inport][:filename]
		table	= params[:inport][:filename].split('.').first
		@content = []
		require 'csv'

		#encoding
		if params.include?(:encoding) and params[:encoding] != settings.default_encoding
 			require 'iconv'
  			file_content = Iconv.iconv("UTF-8", params[:encoding], params[:inport][:tempfile].read)
		end

		CSV.parse(file_content.join) do | row |
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

		set :admin_msg, 'upload complete'
	end
	redirect back

end
