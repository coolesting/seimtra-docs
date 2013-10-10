get '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do
	_prepare(:search => :enable)
	_admin :<%=@t[:file_name]%>
end

post '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do
	_submit :<%=@t[:file_name]%>
end

data :<%=@t[:file_name]%> do<%
	str = ""
	@t[:fields].each do | field |
		if Sbase::Main_key.include?(@t[:types][field].to_sym)
			str += "\n\t\t\t:#{field}\t\t=> {\n\t\t\t\t:pk => true\n\t\t\t}" 
		elsif field == 'uid'
			str += "\n\t\t\t:#{field}\t\t=> _user[:uid]," 
		elsif @t[:types][field] == "integer"
			str += "\n\t\t\t:#{field}\t\t=> 1," 
		elsif @t[:htmls][field] == "select"
			str += "\n\t\t\t:#{field}\t\t=> 1," 
		elsif @t[:htmls][field] == "checkbox"
			str += "\n\t\t\t:#{field}\t\t=> []," 
		else
			str += "\n\t\t\t:#{field}\t\t=> ''," 
		end
	end %>
	{<%=str%>
	}
end

valid :<%=@t[:file_name]%> do<%
	@t[:fields].each do | field | 
		unless Sbase::Main_key.include? @t[:types][field].to_sym 
			if @t[:assoc].has_key? field %>
	if @f.include?(:<%=@t[:assoc][field][1]%>)
		field = _kv :<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%><% if @t[:htmls][field] != "checkbox" %>
		_throw(L[:'the field does not exist '] + L[:'<%=@t[:assoc][field][1]%>']) unless field.include? @f[:<%=@t[:assoc][field][1]%>].to_i<% else %>
		@f[:<%=@t[:assoc][field][1]%>].each do | item |
			_throw(L[:'the field does not exist '] + L[:'<%=@t[:assoc][field][1]%>']) unless field.include? item.to_i
		end<% end %>
	end
	<%
			elsif field == 'changed'
			elsif field == 'created'
			elsif @t[:types][field] == "integer"
	%>
	if @f.include?(:<%=field%>)
		#_throw(L[:'the field cannot be empty '] + L[:'<%=field%>']) if @f[:<%=field%>] != 0
	end
	<%
			else
	%>
	if @f.include?(:<%=field%>)
		_throw(L[:'the field cannot be empty '] + L[:'<%=field%>']) if @f[:<%=field%>].strip.size < 1
	end<%
			end
		end 
	end %>
end
