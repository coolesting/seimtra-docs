Sequel.migration do
	change do
		create_table(:level) do
			column :name, :string
			column :value, :integer, :size => 5, :default => 1
		end
	end
end
