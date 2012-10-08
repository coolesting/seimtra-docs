Sequel.migration do
	change do
		create_table(:block) do
			primary_key :bid
			String :name
			Integer :type
			Integer :display
			Integer :order, :size => 5, :default => 1
			String :description
			DateTime :created
		end
	end
end
