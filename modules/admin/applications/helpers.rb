helpers do

	def menu_focus path, des = nil
		reval = ""
		if request.path.split("/")[2] == path.split("/")[2]
			reval = "focus"
		end
		reval
	end

	# admin_msg
	# send message to user from user
	#
	# == Arguments
	# content, string, message content
	# from_uid, integer, user_info[:uid]
	# to_uid, integer, user id
	# tid, integer, tag id
	def admin_msg content, from_uid, to_uid, tid = 1, mark = 0
		fields = {}
		fields[:content] = content
		fields[:from_uid] = from_uid
		fields[:to_uid] = to_uid
		fields[:tid] = tid
		fields[:created] = Time.now
		fields[:mark] = mark
		DB[:message].insert(fields)
	end

	#remove message
	def admin_msg_rm mid
		ds = DB[:message].filter(:mid => mid)
		if ds.get(:to_uid) == user_info[:uid]
			ds.delete 
		else
			sys_msg "the message is not belong to you."
		end
	end

	def admin_msg_show uid, tid = 1
		DB[:message].filter(:to_uid => uid, :tid => tid).all
	end

end
