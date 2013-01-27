Sequel.migration do
	change do
		create_table(:_task) do
			primary_key :taid
			Integer :uid, :default => 1
			String :method_name
			Integer :tid, :default => 1
			Integer :timeout, :default => 30
			DateTime :changed
		end
	end
end
