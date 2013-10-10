data :_mods do
	{
		:mid		=> {:pk	=> :enable},
		:order		=> 99,
		:status		=> 1,
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:name		=> '',
		:email		=> '',
		:author		=> '',
		:version	=> '',
		:description=> '',
		:dependon	=> '',
		:created	=> Time.now
	}
end

data :_docs do
	{
		:doid		=> {:pk => :enable},
		:uid		=> _user[:uid],
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:name		=> '',
		:body		=> '',
	}
end

data :_file do
	{
		:fid		=> {:pk => :enable},
		:uid		=> _user[:uid],
		:size		=> 1,
		:type		=> '',
		:name		=> '',
		:path		=> '',
		:created	=> Time.now
	}
end

data :_lang do
	{
		:lid		=> {:pk => :enable},
		:label		=> '',
		:content	=> '',
		:uid		=> _user[:uid],
	}
end

data :_menu do
	{
		:mid		=> {:pk => :enable},
		:name		=> '',
		:link		=> '',
		:description=> '',
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:uid		=> _user[:uid],
		:preid		=> 0,
		:order		=> 9,
	}
end

data :_note do
	{
		:nid		=> {:pk => :enable},
		:from_uid	=> 1,
		:to_uid		=> 1,
		:mark		=> 1,
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:content	=> '',
		:created	=> Time.now
	}
end

data :_vars do
	{
		:vid		=> {:pk => :enable},
		:skey		=> '',
		:sval		=> '',
		:description=> '',
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:changed	=> Time.now
	}
end

data :_task do
	{
		:taid		=> {:pk	=> :enable},
		:uid		=> _user[:uid],
		:tid		=> {
			:assoc_table	=> :_tags,
			:assoc_field	=> :tid,
			:assoc_name		=> :name,
			:display_name	=> :tag
		},
		:timeout	=> 30,
		:method_name=> '',
		:changed	=> Time.now
	}
end

data :_tags do
	{
		:tid		=> {:pk	=> :enable},
		:name		=> '',
	}
end


data :_user do
	{
		:uid		=> {:pk => :enable},
		:name		=> '',
		:pawd		=> '',
		:salt		=> '',
		:level		=> 1,
		:created	=> Time.now
	}
end

data :_rule do
	{
		:rid		=> {:pk => :enable},
		:name		=> '',
	}
end

data :_urul do
	{
		:urid		=> {:pk	=> :enable},
		:uid		=> _user[:uid],
		:rid		=> 1,
	}
end

data :_sess do
	{
		:sid		=> 'seimtra',
		:uid		=> _user[:uid],
		:timeout	=> 30,
		:changed	=> Time.now
	}
end

