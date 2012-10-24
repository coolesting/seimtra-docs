Sequel.migration do
	change do
		create_table(:setting) do
			String :skey
			String :sval
			DateTime :changed
		end
	end
end
