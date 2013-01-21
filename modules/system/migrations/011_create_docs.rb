Sequel.migration do
	change do
		create_table(:_docs) do
			primary_key :doid
			Integer :tid, :default => 1
			Integer :uid, :default => 1
			String :name
			Text :body
			String :created
		end
	end
end
