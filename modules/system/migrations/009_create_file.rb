Sequel.migration do
	change do
		create_table(:_file) do
			primary_key :fid
			Integer :uid, :default => 1
			String :filetype, :size => 10
			String :name
			String :path
			DateTime :created
		end
	end
end
