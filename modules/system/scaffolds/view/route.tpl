
#display
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do

	sys_opt :new, :search
	ds = DB[:<%=@t[:table_name]%>]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if settings.sys_opt.include? :search
		@search = {<% @t[:fields].each do | field | %>:<%=field%> => '<%
			if @t[:assoc].has_key? field
				%><%=@t[:assoc][field][2]%>', <%
			else
				%><%=field%>', <%
			end
		end %>}
	end

	#order
	if @qs[:order]
		if @qs.has_key? :desc
			ds = ds.reverse_order(@qs[:order].to_sym)
			@qs.delete :desc
		else
			ds = ds.order(@qs[:order].to_sym)
			@qs[:desc] = 'yes'
		end
	end

	Sequel.extension :pagination
 	@<%=@t[:table_name]%> = ds.paginate(@page_curr, @page_size, ds.count)
 	@page_count = @<%=@t[:table_name]%>.page_count

	slim :<%=@t[:layout]%>_<%=@t[:file_name]%>

end
