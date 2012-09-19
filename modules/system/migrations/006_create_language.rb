Sequel.migration do
	change do
		create_table(:language) do
			String :label
			String :lang_type
			String :content
			Integer :mid
		end
	end
end
