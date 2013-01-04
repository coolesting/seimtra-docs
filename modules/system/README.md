## INTRODUCTION

System module, a core module that defines the basic responsibility and function to this WebOS, provides the basic structure to data defined, and interface method for extension module.

## BASIC DATA STRUCTURE

Any db tables, methods, templates(except layout.slim) of core module that use the sign '_' as prefix.

#### Basic data construct

	_mods		-- module information, define the module basic content
	_vars		-- system setting variables
	_menu		-- basic navigation menu, basically, every page needs it
	_lang		-- language translation, like i18n
	_task		-- background task

	_user		-- user basic data
	_sess		-- user session
	_tick		-- ticket for logining user

#### Extension data construct

	_file		-- upload file
	_tags		-- classify data content by the tag
	_note		-- commumication between users and module applications, or from user to user
	_docs		-- page basic element, it is document

About interface method see the helpers.rb of system module.



## EXTENSION MODULE

Except the core module, otherwise is extension module.
Extension module that needs to add the the module name as prefix, includes the database table name, method name, template name.

like a *blog* module, 
we define the article table as *blog_article*, 
create the article with method *blog_add_article*
template like, *blog_post*, *blog_list* ...








