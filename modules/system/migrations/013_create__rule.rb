Sequel.migration do
	change do
		create_table(:_rule) do
			primary_key :rid
			String :name
		end
	end
end
