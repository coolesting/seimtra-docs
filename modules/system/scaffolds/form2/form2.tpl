form.form2 action="#{_url(request.path)}" method="post" id="form"<% 
	@t[:fields].each do | field | 
		html_type = @t[:htmls][field]
		html_type = "unknown" if Sbase::Main_key.include?(@t[:types][field].to_sym) or field == 'changed'
		lname = @t[:assoc].has_key?(field) ? @t[:assoc][field][2] : field

		if html_type == "unknown" %>
		<% elsif html_type == "string" %>
	p : label = L[:<%=lname%>]
	p : input type="text" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}"
		<% elsif html_type == "integer" %>
	p : label = L[:<%=lname%>]
	p : input type="number" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}" min="1" max="99999"
		<% elsif html_type == "text" %>
	p : label = L[:<%=lname%>]
	p : textarea name="<%=field%>" required="required" = @f[:<%=field%>]
		<% elsif html_type == "radio" %>
	p : label = L[:<%=lname%>]
	- <%=@t[:assoc][field][0]%>s = _kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
	p
		- <%=@t[:assoc][field][0]%>s.each do | k,v |
			- checked = @f[:<%=@t[:assoc][field][1]%>] == k ? "checked" : ""
			input id="radio_<%=@t[:assoc][field][1]%>_#{k}" type="radio" name="<%=@t[:assoc][field][1]%>" checked="#{checked}" value="#{k}"
			label for="radio_<%=@t[:assoc][field][1]%>_#{k}" = v
			br
		<% elsif html_type == "select" %>
	p : label = L[:<%=lname%>]
	- <%=@t[:assoc][field][0]%>s = _kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
	p : select name="<%=@t[:assoc][field][1]%>" required="required"
		- <%=@t[:assoc][field][0]%>s.each do | k,v |
			- selected = @f[:<%=@t[:assoc][field][1]%>] == k ? "selected" : ""
			option selected="#{selected}" value="#{k}" = v
		<% elsif html_type == "checkbox" %>
	p : label = L[:<%=lname%>]
	p
		- <%=@t[:assoc][field][0]%>s = _kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		- <%=@t[:assoc][field][1]%>s = []
		- if @f[:<%=@t[:assoc][field][1]%>] != ""
			- if @f[:<%=@t[:assoc][field][1]%>].index(".")
				- <%=@t[:assoc][field][1]%>s = @f[:<%=@t[:assoc][field][1]%>].split(".") 
			- else
				- <%=@t[:assoc][field][1]%>s << @f[:<%=@t[:assoc][field][1]%>]

	p
		- <%=@t[:assoc][field][0]%>s.each do | k,v |
			- checked = <%=@t[:assoc][field][1]%>s.include?(k.to_s) ? "checked" : ""
			span.checkbox
				input id="checkbox_<%=@t[:assoc][field][1]%>_#{k}" type="checkbox" name="<%=@t[:assoc][field][1]%>[]" checked="#{checked}" value="#{k}"
				label for="checkbox_<%=@t[:assoc][field][1]%>_#{k}" = v
		<% else %>
	p : label = L[:<%=lname%>]
	p : input type="<%=html_type%>" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}"<% 
		end

	end %>
	p : input type="submit" value="#{L[:done]}"
