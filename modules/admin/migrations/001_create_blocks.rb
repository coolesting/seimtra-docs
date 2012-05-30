Sequel.migration do
	change do
		create_table(:blocks) do
			primary_key :bid
			Integer :mid
			String :name
			String :type
			String :display
			String :layout
			Integer :order, :size => 5, :default => 9
			String :description
			DateTime :created
		end
	end
end
