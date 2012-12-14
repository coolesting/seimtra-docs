Sequel.migration do
	change do
		create_table(:user_session) do
			String :sid, :default => 50
			Integer :uid
			Datetime :changed
		end
	end
end
