Sequel.migration do
	change do
		create_table(:_tick) do
			primary_key :tiid
			Integer :uid
			String :name, :size => 50
			String :agent
			String :ip
			Datetime :created
		end
	end
end
