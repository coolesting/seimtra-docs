Sequel.migration do
	change do
		create_table(:session) do
			String :sid
			Integer :uid
			Datatime :changed
		end
	end
end
