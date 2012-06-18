Sequel.migration do
	change do
		create_table(:setting) do
			primary_key :sid
			Integer :mid
			String :skey
			String :sval
			DateTime :changed
		end
	end
end
