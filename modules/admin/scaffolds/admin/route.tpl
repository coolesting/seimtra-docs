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

	sys_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>

end

#new a record
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>/new' do

	@title = 'Create a new <%=@t[:file_name]%>'
	@rightbar << :save
	<%=@t[:file_name]%>_set_fields
	sys_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>_form

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

	@title = 'Delete the <%=@t[:file_name]%> by id <%=@t[:key_id]%>, are you sure ?'
	DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>].to_i).delete
	redirect "/<%=@t[:layout]%>/<%=@t[:file_name]%>"

end

#edit the record
get '/<%=@t[:layout]%>/<%=@t[:file_name]%>/edit/:<%=@t[:key_id]%>' do

	@title = 'Edit the <%=@t[:file_name]%>'
	@rightbar << :save
	@fields = DB[:<%=@t[:table_name]%>].filter(:<%=@t[:key_id]%> => params[:<%=@t[:key_id]%>]).all[0]
 	<%=@t[:file_name]%>_set_fields
 	sys_tpl :<%=@t[:layout]%>_<%=@t[:file_name]%>_form

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
		field = sys_kv <%=@t[:assoc][field][0]%>, :<%=@t[:assoc][field][1]%>, :<%=@t[:assoc][field][2]%>
					<% if @t[:htmls][field] != "checkbox" %>
		sys_throw "The <%=@t[:assoc][field][1]%> field isn't existing." unless field.include? @fields[:<%=@t[:assoc][field][1]%>].to_i<% else %>
		@fields[:<%=@t[:assoc][field][1]%>].each do | item |
			sys_throw "The <%=@t[:assoc][field][1]%> field isn't existing." unless field.include? item.to_i
		end
		<%
					end
				elsif field == 'created'
				elsif field == 'changed'
				else
		%>
		sys_throw "The <%=field%> field cannot be empty." if @fields[:<%=field%>].strip.size < 1
		<%
				end
			end 
		end %>
	end

end
