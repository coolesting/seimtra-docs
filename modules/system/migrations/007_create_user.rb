Sequel.migration do
	change do
		create_table(:_user) do
			primary_key :uid
			String :name, :size => 20
			String :pawd, :size => 50
			String :salt, :size => 5
			Integer :level, :size => 100, :default => 1
			Datetime :created
		end
	end
end
