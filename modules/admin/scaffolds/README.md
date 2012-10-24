## the scaffold file

view.tpl
form.tpl
route.tpl
config.sfile
menu.install
setting.install



## the availble option of @t template variable

:operator, symbol ---- :create, :alter, :drop, :rename
:fields,array 	---- [field1_str, field2, field3]
:types,	hash	---- {field1 => type_name, field2 => type_name}
:htmls,	hash	---- {field1 => html_type, field2 => html_type}
:others,hash	---- {field1 => {attr => val}, field2 => {attr1 => val1, attr2 => val2}}
:assoc,	hash	---- {field1 => [table, field1, assoc_field], field2 => [table, field2, assoc_field]}

:module_name,string
:layout,	string
:file_name, string
:table_name, string
:key_id,	string

:menu,		hash	---- {:name => 'menu_name', :des => 'description',,,}



## the config.sfile necessary option

run=off

layout
author
version
