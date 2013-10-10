.list2<% unless @t[:assoc].empty?
		@t[:assoc].each do | field, data | %>
	- <%=data[0]%>s = _kv(:<%=data[0]%>, :<%=data[1]%>, :<%=data[2]%>)<% end %><% end %>
	- @<%=@t[:file_name]%>.each do | row |
		.list-body<% @t[:fields].each do | field | 
				if @t[:assoc].has_key? field
					if @t[:htmls][field] == "checkbox"%>
			p
				- row[:<%=@t[:assoc][field][1]%>].split(".").each do | item |
					label = <%=@t[:assoc][field][0]%>s[item.to_i]
					label &nbsp;<% 
					else %>
			p = <%=@t[:assoc][field][0]%>s[row[:<%=field%>]]<%
					end
				else %>
			p = row[:<%=field%>]<% end %><% end %>

- if @page_count > 1
	p.page_bar
		- for i in 1..@page_count
			- page_focus = i == @page_curr ? "page_focus" : ""
			span class="#{page_focus}" : a href="#{_url2(request.path, :page_curr => i)}" = i
