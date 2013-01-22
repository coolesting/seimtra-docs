#display
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>' do

	@rightbar += [:new, :search]
	ds = DB[:<%=@t[:table_name]%>]

	#search content
	ds = ds.filter(@qs[:sw].to_sym => @qs[:sc]) if @qs[:sw] and @qs[:sc]

	#search condition
	if @rightbar.include? :search
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

	_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>

end

#new a record
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>/new' do

	@title = L[:'create a new one '] + L[:'<%=@t[:file_name]%>']
	@rightbar << :save
	<%=@t[:file_name]%>_set_fields
	_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>_form

end

post '/<%=@t[:layout]%>/<%=@t[:file_name]%>/new' do

	<%=@t[:file_name]%>_set_fields
	<%=@t[:file_name]%>_valid_fields
	<% if @t[:fields].include?('created') %>@fields[:created] = Time.now<% end %>
	<% if @t[:fields].include?('changed') %>@fields[:changed] = Time.now<% end %>
	<% @t[:htmls].each do | field, html |
		if html == "checkbox"%>
	@fields[:<%=@t[:assoc][field][1]%>] = @fields[:<%=@t[:assoc][field][1]%>].join "."<%
		end
	end %>
	DB[:<%=@t[:table_name]%>].insert(@fields)
	redirect "/<%=@t[:layout]%>/<%=@t[:file_name]%>"

end

#delete the record
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>/rm/:<%=@t[:key_id]%>' do

	_msg L[:'delete the record by id '] + params[:'<%=@t[:key_id]%>']
	DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i).delete
	redirect "/<%=@t[:layout]%>/<%=@t[:file_name]%>"

end

#edit the record
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	@title = L[:'edit the '] + L[:'<%=@t[:file_name]%>']
	@rightbar << :save
	@fields = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>]).all[0]
 	<%=@t[:file_name]%>_set_fields
 	_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>_form

end

post '/<%=@t[:layout]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	<%=@t[:file_name]%>_set_fields
	<%=@t[:file_name]%>_valid_fields
	<% if @t[:fields].include?('changed') %>@fields[:changed] = Time.now<% end %>
	<%
		@t[:htmls].each do | field, html |
			if html == "checkbox"
	%>@fields[:<%=@t[:assoc][field][1]%>] = @fields[:<%=@t[:assoc][field][1]%>].join "."<%
			end
		end
	%>
	<% if @t[:types][@t[:key_id]].to_sym == :integer 
	%>DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i).update(@fields)<% 
	else 
	%>DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>]).update(@fields)<% end %>
	redirect "/<%=@t[:layout]%>/<%=@t[:file_name]%>"

end

helpers do

	#fill the @fields with the default value
	#the @fields will be write into database, or display by template to frontground
	def <%=@t[:file_name]%>_set_fields
		<%
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
			end 
			str = str.chomp ','
		%>
		default_values = {<%=str%>
		}

		default_values.each do | k, v |
			unless @fields.include? k
				@fields[k] = params[k] ? params[k] : v
			end
		end

	end

	def <%=@t[:file_name]%>_valid_fields
		<% @t[:fields].each do | field | 
			unless Sbase::Main_key.include? @t[:types][field].to_sym 
				if @t[:assoc].has_key? field %>
		field = _kv :<%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>
					<% if @t[:htmls][field] != "checkbox" %>
		_throw(L[:'the field does not exist '] + L[:'<%=@t[:assoc][field][1]%>']) unless field.include? @fields[:<%=@t[:assoc][field][1]%>].to_i<% else %>
		@fields[:<%=@t[:assoc][field][1]%>].each do | item |
			_throw(L[:'the field does not exist '] + L[:'<%=@t[:assoc][field][1]%>']) unless field.include? item.to_i
		end
		<%
					end
				elsif field == 'changed'
 				elsif @t[:types][field] == "integer"
		%>
		#_throw(L[:'the field cannot be empty '] + L[:'<%=field%>']) if @fields[:<%=field%>] != 0
		<%
				else
		%>
		_throw(L[:'the field cannot be empty '] + L[:'<%=field%>']) if @fields[:<%=field%>].strip.size < 1
		<%
				end
			end 
		end %>
	end

end
