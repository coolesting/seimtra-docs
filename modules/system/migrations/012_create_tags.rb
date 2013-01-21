Sequel.migration do
	change do
		create_table(:_tags) do
			primary_key :tid
			String :name
		end
	end
end
