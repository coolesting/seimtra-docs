form.form action="#{_url2(request.path)}" method="post" id="form"
	p
		input.button.mr10 type="submit" value="#{L[:done]}"
		a href="#{_url(request.path)}"
			button.button = L[:return]<% 
	loadeditor = 'no'
	loadpicture = 'no'
	@t[:fields].each do | field | 
		classstr = ' ' 
		if @t[:others].include?(field)
			if @t[:others][field].include?(:class)
				classstr = ' class="' + @t[:others][field][:class] + '" '
				if @t[:others][field][:class] == 'ly_picture'
					loadpicture = 'yes'
				end
			end
		end

		html_type = @t[:htmls][field]
		html_type = "unknown" if Sbase::Main_key.include?(@t[:types][field].to_sym) or field == 'created' or field == 'changed'
		lname = @t[:assoc].has_key?(field) ? @t[:assoc][field][2] : field

		if html_type == "unknown" %>
		<% elsif html_type == "string" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
		p : input<%=classstr%>type="text" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}"
		<% elsif html_type == "integer" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
		p : input<%=classstr%>type="number" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}" min="1" max="99999"
		<% elsif html_type == "text" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]<% loadeditor = 'yes' %>
		p : textarea<%=classstr%>name="<%=field%>" required="required" = @f[:<%=field%>]
		<% elsif html_type == "radio" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
		- <%=@t[:assoc][field][0]%>s = _kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		p<%=classstr%>
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- checked = @f[:<%=@t[:assoc][field][1]%>] == k ? "checked" : ""
				input id="radio_<%=@t[:assoc][field][1]%>_#{k}" type="radio" name="<%=@t[:assoc][field][1]%>" checked="#{checked}" value="#{k}"
				label for="radio_<%=@t[:assoc][field][1]%>_#{k}" = v
				br
		<% elsif html_type == "select" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
		- <%=@t[:assoc][field][0]%>s = _kv(:<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>)
		p : select name="<%=@t[:assoc][field][1]%>"<%=classstr%>
			- <%=@t[:assoc][field][0]%>s.each do | k,v |
				- selected = @f[:<%=@t[:assoc][field][1]%>] == k ? "selected" : ""
				option selected="#{selected}" value="#{k}" = v
		<% elsif html_type == "checkbox" %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
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
				span.checkbox<%=classstr%>
					input id="checkbox_<%=@t[:assoc][field][1]%>_#{k}" type="checkbox" name="<%=@t[:assoc][field][1]%>[]" checked="#{checked}" value="#{k}"
					label for="checkbox_<%=@t[:assoc][field][1]%>_#{k}" = v
		<% else %>
	- if @f.has_key?(:<%=field%>)
		p : label = L[:<%=lname%>]
		p : input<%=classstr%> type="<%=html_type%>" name="<%=field%>" required="required" value="#{@f[:<%=field%>]}"<% 
		end

	end %>
<% if loadeditor == 'yes' %>
	== _inc(:_editor)

javascript:
	$('.form textarea').linyu_editor();
<% end %> 
<% if loadpicture == 'yes' %>
	== _inc(:_picture)
<% end %>
