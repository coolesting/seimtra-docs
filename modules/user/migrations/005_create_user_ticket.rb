Sequel.migration do
	change do
		create_table(:user_ticket) do
			String :name
			Integer :uid
			String :location
			String :ip
			Datetime :created
		end
	end
end
