Sequel.migration do
	change do
		create_table(:blocks) do
			primary_key :bid
			Integer :mid
			String :name
			Integer :type
			Integer :display
			Integer :order, :size => 5, :default => 1
			String :description
			DateTime :created
		end
	end
end
