Sequel.migration do
	change do
		create_table(:module_assoc) do
			String :module_name
			String :table_name
		end
	end
end
