Sequel.migration do
	change do
		create_table(:_sess) do
			String :sid, :default => 50
			Integer :uid
			Integer :timeout
			Datetime :changed
		end
	end
end
