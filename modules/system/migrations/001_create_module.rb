Sequel.migration do
	change do
		create_table(:module) do
			primary_key :mid
			Integer :load_order
			String :name
			String :group
			String :opened
			String :status
			String :email
			String :author
			DateTime :created
			String :version
			String :description
			String :dependon
		end
	end
end
