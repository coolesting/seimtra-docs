Sequel.migration do
	change do
		create_table(:_tags) do
			primary_key :tid
			Integer :mid
			String :name
			Integer :uid, :default => 1
		end
	end
end
