
#display
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do

	ds = DB[:<%=@t[:table_name]%>]

	#search content
	condition = {}
	# puts the condition in here, likes, condition[:id] = @qs[:id] if @qs[:id]

	ds = ds.filter(condition) unless condition.empty?

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
