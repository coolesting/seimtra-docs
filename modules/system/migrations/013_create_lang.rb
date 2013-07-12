Sequel.migration do
	change do
		create_table(:_lang) do
			primary_key :lid
			String :label
			String :content
			Integer :uid, :default => 1
		end
	end
end
