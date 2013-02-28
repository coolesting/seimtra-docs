Sequel.migration do
	change do
		create_table(:_urul) do
			primary_key :urid
			Integer :uid
			Integer :rid
		end
	end
end
