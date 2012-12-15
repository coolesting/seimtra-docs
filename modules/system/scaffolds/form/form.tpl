form action="#{request.path}" method="post" id="form"
	ul.ul<% 
	@t[:fields].each do | field | 

		html_type = @t[:htmls][field]
		html_type = "unknown" if Sbase::Main_key.include?(@t[:types][field].to_sym) or field == 'changed'
		lname = @t[:assoc].has_key?(field) ? @t[:assoc][field][2] : field

		if html_type == "unknown" %>
		<% elsif html_type == "string" %>
		li : label = L[:<%=lname%>]
		li : input type="text" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"
		<% elsif html_type == "integer" %>
		li : label = L[:<%=lname%>]
		li : input type="number" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}" min="1" max="99999"
		<% elsif html_type == "text" %>
		li : label = L[:<%=lname%>]
		li : textarea name="<%=field%>" required="required" = @fields[:<%=field%>]
		<% elsif html_type == "radio" %>
		li : label = L[:<%=lname%>]
		- <%=@t[:assoc][field][0]%>s = sys_kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		li
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- checked = @fields[:<%=@t[:assoc][field][1]%>] == k ? "checked" : ""
				input id="radio_<%=@t[:assoc][field][1]%>_#{k}" type="radio" name="<%=@t[:assoc][field][1]%>" checked="#{checked}" value="#{k}"
				label for="radio_<%=@t[:assoc][field][1]%>_#{k}" = v
				br
		<% elsif html_type == "select" %>
		li : label = L[:<%=lname%>]
		- <%=@t[:assoc][field][0]%>s = sys_kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		li : select name="<%=@t[:assoc][field][1]%>" required="required"
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- selected = @fields[:<%=@t[:assoc][field][1]%>] == k ? "selected" : ""
				option selected="#{selected}" value="#{k}" = v
		<% elsif html_type == "checkbox" %>
		li : label = L[:<%=lname%>]
		- <%=@t[:assoc][field][0]%>s = sys_kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		- <%=@t[:assoc][field][1]%>s = []
		- if @fields[:<%=@t[:assoc][field][1]%>] != ""
			- if @fields[:<%=@t[:assoc][field][1]%>].index(".")
				- <%=@t[:assoc][field][1]%>s = @fields[:<%=@t[:assoc][field][1]%>].split(".") 
			- else
				- <%=@t[:assoc][field][1]%>s << @fields[:<%=@t[:assoc][field][1]%>]

		li
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- checked = <%=@t[:assoc][field][1]%>s.include?(k.to_s) ? "checked" : ""
				span.checkbox
					input id="checkbox_<%=@t[:assoc][field][1]%>_#{k}" type="checkbox" name="<%=@t[:assoc][field][1]%>[]" checked="#{checked}" value="#{k}"
					label for="checkbox_<%=@t[:assoc][field][1]%>_#{k}" = v
		<% else %>
		li : label = L[:<%=lname%>]
		li : input type="<%=html_type%>" name="<%=field%>" required="required" value="#{@fields[:<%=field%>]}"<% 
		end

	end %>
		li : input type="submit" value="submit"

