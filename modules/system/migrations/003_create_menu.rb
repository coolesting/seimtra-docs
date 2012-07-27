Sequel.migration do
	change do
		create_table(:menu) do
			primary_key :mid
			String :name
			String :type, :default => "default"
			String :link
			String :description
			Integer :preid, :default => 0
			Integer :order, :size => 5, :default => 1
		end
	end
end
