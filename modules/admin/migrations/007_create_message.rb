Sequel.migration do
	change do
		create_table(:message) do
			primary_key :mid
			Integer :from_uid
			Integer :to_uid
			Integer :tid
			String :content
			Integer :mark
		end
	end
end
