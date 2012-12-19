Sequel.migration do
	change do
		create_table(:user_setting) do
			Integer :uid
			Integer :level
			Integer :integral
			Integer :timeout
			String :layout
			Datetime :changed
			index :uid
		end
	end
end
