get '/system/iocsv' do
	slim :system_iocsv
end

get '/system/iocsv/output/csvfile.csv' do
	require 'csv'
	csv_file = CSV.generate do |csv|
		csv << ["a", "b", "c"]
		csv << ["aa", "bb"]
	end

	content_type 'application/csv'
	csv_file
end

post '/system/iocsv' do
end
