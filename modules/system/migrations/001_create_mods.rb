Sequel.migration do
	change do
		create_table(:_mods) do
			primary_key :mid
			Integer :order, :default => 99
			Integer :status
			String :name
			String :type
			String :email
			String :author
			String :version
			String :description
			String :dependon
			DateTime :created
		end
	end
end
