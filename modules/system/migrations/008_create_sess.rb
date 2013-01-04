Sequel.migration do
	change do
		create_table(:_sess) do
			String :ticket, :default => 50
			Integer :uid
			Datetime :changed
		end
	end
end
