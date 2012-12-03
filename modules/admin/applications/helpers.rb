helpers do

	def menu_focus path, des = nil
		reval = ""
		if request.path.split("/")[2] == path.split("/")[2]
			reval = "focus"
		end
		reval
	end

	def sys_opt *argv
		set :sys_opt, argv
	end

end
