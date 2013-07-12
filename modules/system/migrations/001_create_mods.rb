Sequel.migration do
	change do
		create_table(:_mods) do
			primary_key :mid
			Integer :order, :default => 99
			Integer :status
			Integer :tid
			String :name
			String :email
			String :author
			String :version
			String :description
			String :dependence
			DateTime :created
		end
	end
end
