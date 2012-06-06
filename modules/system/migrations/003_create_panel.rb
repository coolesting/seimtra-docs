Sequel.migration do
	change do
		create_table(:panel) do
			primary_key :pid
			Integer :mid
			String :menu
			String :name
			String :link
			String :description
			Integer :status, :size => 1, :default => 0
			Integer :level, :size => 5, :default => 1
			Integer :order, :size => 5, :default => 1
		end
	end
end
