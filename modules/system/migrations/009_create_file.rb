Sequel.migration do
	change do
		create_table(:_file) do
			primary_key :fid
			Integer :uid, :default => 1
			Integer :size
			String :type, :size => 15
			String :name
			String :path
			DateTime :created
		end
	end
end
