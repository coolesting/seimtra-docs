helpers do

	# _note_send
	# send note to user from user
	#
	# == Arguments
	# content, string, note content
	# from_uid, integer, _user[:uid]
	# to_uid, integer, user id
	# tid, integer, tag id
	def _note_send content, from_uid, to_uid, type = 'default', mark = 0
		fields = {}
		fields[:content] = content
		fields[:from_uid] = from_uid
		fields[:to_uid] = to_uid
		fields[:tid] = _tag(type)
		fields[:created] = Time.now
		fields[:mark] = mark
		DB[:_note].insert(fields)
	end

	#remove note
	def _note_rm nid, uid = 0
		uid = _user[:uid] if uid == 0
		ds 	= DB[:_note].filter(:nid => nid)
		if ds.get(:to_uid) == uid
			ds.delete 
		else
			_msg L[:'the note is not belong to you.']
		end
	end

	def _note_all type = nil
		DB[:_note].filter(:to_uid => _user[:uid]).delete
		_msg L[:'all of notes have been clean']
	end

	#get note by type, uid
	def _note type, uid = 0
		uid = _user[:uid] if uid == 0
		DB[:_note].filter(:to_uid => uid, :tid => _tag(type)).all
	end

end
