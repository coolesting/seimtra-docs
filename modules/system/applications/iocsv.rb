get '/system/iocsv' do
	slim :system_iocsv
end

#get db table as csv file output
get '/system/iocsv/export' do

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

   		attachment "#{params[:export]}.csv"
		csv_file
	else
		redirect back
	end

end

#upload file
post '/system/iocsv/inport' do

	if params[:inport] and params[:inport][:tempfile] and params[:inport][:filename]
		table	= params[:inport][:filename].split('.').first
		@content = []
		require 'csv'
		CSV.parse(params[:inport][:tempfile].read) do | row |
			@content << row
		end

		#input the @content to database
		columns = @content.shift
		@content.shift

		@content.each do | row |
			data = {}
			columns.zip(row) { |a,b| data[a.to_sym] = b }
			DB[table.to_sym].insert(data)
		end

		set :sys_msg, 'upload complete'
	end
	redirect back

end
