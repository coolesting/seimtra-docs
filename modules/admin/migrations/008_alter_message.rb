Sequel.migration do
	change do
		alter_table(:message) do
			add_column :created, :datetime
		end
	end
end
