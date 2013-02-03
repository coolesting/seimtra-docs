Sequel.migration do
	change do
		create_table(:_vars) do
			primary_key :vid
			String :skey
			String :sval
			Integer :tid, :default => 1
			DateTime :changed
		end
	end
end
