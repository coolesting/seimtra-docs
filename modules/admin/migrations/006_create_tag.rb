Sequel.migration do
	change do
		create_table(:tag) do
			primary_key :tid
			String :name
		end
	end
end
