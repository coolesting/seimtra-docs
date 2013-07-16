get '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do
	@search = _data(:<%=@t[:file_name]%>).keys
	@rightbar << :search
	<%=@t[:file_name]%>_admin
end

post '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do
	<%=@t[:file_name]%>_submit
end

helpers do

	#get the form
	def <%=@t[:file_name]%>_form fields = [], tpl = :<%=@t[:file_name]%>_form, layout = :layout
		@t[:title] 	= L[:'edit the '] + L[:'<%=@t[:file_name]%>']
		id 			= @qs.include?(:<%=@t[:key_id]%>) ? @qs[:<%=@t[:key_id]%>].to_i : 0
		if id == 0
			data = _data(:<%=@t[:file_name]%>)
		else
			data = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => id).first 
		end
		_set_fields fields, data
		_tpl tpl, layout
	end

	#get the view of admin
	def <%=@t[:file_name]%>_admin fields = [], tpl = :<%=@t[:file_name]%>_admin, layout = :layout
		#edit content
		if @qs[:opt] == 'form'
			<%=@t[:file_name]%>_form

		#remove record
		elsif @qs[:opt] == 'rm'
			<%=@t[:file_name]%>_rm

		#display view
		else
			ds = DB[:<%=@t[:table_name]%>]

			#search content
			ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

			#order
			if @qs[:order]
				ds = ds.order(@qs[:order].to_sym)
			else
				ds = ds.reverse_order(:<%=@t[:key_id]%>)
			end

			Sequel.extension :pagination
			@<%=@t[:table_name]%> = ds.paginate(@page_curr, @page_size, ds.count)
			@page_count = @<%=@t[:table_name]%>.page_count
			_tpl tpl, layout
		end
	end

	#submit the data
	def <%=@t[:file_name]%>_submit fields = [], redirect_path = request.path
		id 	= @qs.include?(:<%=@t[:key_id]%>) ? @qs[:<%=@t[:key_id]%>].to_i : 0
		if id == 0
			data = _data(:<%=@t[:file_name]%>)
			_set_fields fields, data, true
		else
			data = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => id).first 
			_set_fields fields, data
		end
		_valid :<%=@t[:file_name]%>

		#insert
		if id == 0<% if @t[:fields].include?('created') %>
			@f[:created] = Time.now<% end %>
			DB[:<%=@t[:table_name]%>].insert(@f)
		#update
		else
			DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => id).update(@f)
		end
		redirect redirect_path unless redirect_path == nil
	end

	#remove the record
	def <%=@t[:file_name]%>_rm id = 0
		if id == 0 and @qs.include?(:<%=@t[:key_id]%>)
			id = @qs[:<%=@t[:key_id]%>].to_i
		end
		unless id == 0
			_msg L[:'delete the record by id '] + id.to_s
			DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => id).delete
		end
		redirect back
	end

end

data :<%=@t[:file_name]%> do<%
	str = ""
	@t[:fields].each do | field |
		unless Sbase::Main_key.include?(@t[:types][field].to_sym)
			if field == 'changed'
			elsif field == 'created'
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
