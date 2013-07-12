Sequel.migration do
	change do
		create_table(:_menu) do
			primary_key :mid
			String :name
			String :link
			String :description
			Integer :tid, :default => 1
			Integer :uid, :default => 1
			Integer :preid, :default => 0
			Integer :order, :size => 5, :default => 9
		end
	end
end
