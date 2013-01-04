Sequel.migration do
	change do
		create_table(:_docs) do
			primary_key :did
			Integer :tid
			Integer :uid, :default => 1
			String	:title
			Text :body
			DateTime :created
			DateTime :changed
		end
	end
end
