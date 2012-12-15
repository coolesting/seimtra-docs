Sequel.migration do
	change do
		create_table(:user_base) do
			Integer :uid
			String :nickname, :size => 20
			String :description
			String :picture
			String :email
			Datetime :changed
			index :uid
		end
	end
end
