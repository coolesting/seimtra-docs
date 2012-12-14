Sequel.migration do
	change do
		create_table(:user_info) do
			Integer :uid
			Integer :level
			Integer :integral
			Integer :timeout
			String :nickname
			String :email
			String :picture
			Datetime :changed
			Text :resume
		end
	end
end
