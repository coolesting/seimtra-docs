Sequel.migration do
	change do
		create_table(:_note) do
			primary_key :nid
			Integer :from_uid
			Integer :to_uid
			Integer :mark
			Integer :tid
			String :content
			DateTime :created
		end
	end
end
