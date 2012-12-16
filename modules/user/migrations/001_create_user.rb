Sequel.migration do
	change do
		create_table(:user) do
			primary_key :uid
			String :name, :size => 20
			String :pawd, :size => 50
			String :salt, :size => 5
			Datetime :created
		end
	end
end
