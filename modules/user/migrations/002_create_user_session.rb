Sequel.migration do
	change do
		create_table(:user_session) do
			String :sid
			Integer :uid
			Datatime :changed
		end
	end
end
