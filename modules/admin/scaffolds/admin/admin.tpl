form.form
	p
		a href="#{_url(request.path, :opt => 'form')}"
			button.button = L[:create]

table.table
	thead<% @t[:fields].each do | field | %><% origin = field; field = @t[:assoc][field][2] if @t[:assoc].has_key?(field) %>
		th : a href="#{_url(request.path, :order => '<%=origin%>')}" = L[:<%=field%>]<% end %>
		th
		th
	tbody<% unless @t[:assoc].empty?
			@t[:assoc].each do | field, data | %>
		- <%=data[0]%>s = _kv(:<%=data[0]%>, :<%=data[1]%>, :<%=data[2]%>)<% end %><% end %>
		- @<%=@t[:file_name]%>.each do | row |
			tr<% @t[:fields].each do | field | 
					if @t[:assoc].has_key? field
						if @t[:htmls][field] == "checkbox"%>
				td
					- row[:<%=@t[:assoc][field][1]%>].split(".").each do | item |
						label = <%=@t[:assoc][field][0]%>s[item.to_i]
						label &nbsp;<% 
						else %>
				td = <%=@t[:assoc][field][0]%>s[row[:<%=field%>]]<%
						end
					else %>
				td = row[:<%=field%>]<% end %><% end %>
				td
					a href="#{_url(request.path, :opt => 'form', :<%=@t[:key_id]%> => row[:<%=@t[:key_id]%>])}"
						img src="#{_public('/icons/edit.png')}"
				td
					a href="#{_url(request.path, :opt => 'rm', :<%=@t[:key_id]%> => row[:<%=@t[:key_id]%>])}"
						img src="#{_public('/icons/delete.png')}"

link rel='stylesheet' type='text/css' href='#{_public("/css/table-1.css")}'

- if @page_count > 1
	p.page_bar
		- for i in 1..@page_count
			- page_focus = i == @page_curr ? "page_focus" : ""
			span class="#{page_focus}" : a href="#{_url2(request.path, :page_curr => i)}" = i
