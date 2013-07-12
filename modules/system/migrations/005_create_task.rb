Sequel.migration do
	change do
		create_table(:_task) do
			primary_key :taid
			Integer :uid, :default => 1
			Integer :tid, :default => 1
			Integer :timeout, :default => 30
			String :method_name
			DateTime :changed
		end
	end
end
