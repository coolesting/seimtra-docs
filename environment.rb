require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'

configure do

	# ================= db config ================= 

	## 
	# mysql
	#
	#	yum install mysql*
	#	gem install mysql
	#	/etc/init.d/mysqld start
	#
	# create database and user
	#
	#	mysql -u root -p
	#	create user 'myuser'@'localhost' identified by '123456';
	#	create database mydb;
	#	grant all privileges on *.* to 'myuser'@'localhost' with grant option;
	#	granl all on mydb.* to 'myuser'@'localhost';
	#	quit
	#
	# change the password
	#
	#	mysql -u root -p
	#	use mysql;
	#	update user set password=PASSWORD("new-password") where User="myuser"
	set :db_mysql, 'mysql://localhost/mydb?user=myuser&password=123456'	

	set :db_memory, 'sqlite:/'

	##
	# postgresql
	#
	#	yum install postgres*
	#	gem install pg
	#	initdb -D db_pg
	#	postgres -D db_pg
	#	createdb db_pg
	set :db_pg, 'postgres://localhost/db_pg'	

	##
	# sqlite
	#
	#	yum install sqlite3*
	#	gem install sqlite3
	set :db_sqlite, 'sqlite://db/data.db'

	#set the db_connect here, which you want
	DB_connect = settings.db_sqlite
	DB = Sequel.connect(DB_connect)
	

	# ================= setting config ================= 

	#set the log for output
#  	disable :logging
#  	set :log, false

	set :cache_static_file, false

	set :mydomain, ''

	set :mypath, '/'


	# ================== file path =====================
	set :tmp_path, Dir.pwd + '/tmp'

	#set :upload_path, '/var/upload'
	set :upload_path, Dir.pwd + '/db/upload'
	Dir.mkdir settings.upload_path unless File.exist? settings.upload_path

	set :cache_path, '/var/cache/seimtra'

	set :log_path, Dir.pwd + '/log'


end

module Seimtra

	module Sbase

		#generated file when module is created
		File_generated 		= 	{
			:info			=>	'stores/install/_mods',
			:readme			=>	'README.md'
		}

		#installed module files
		File_installer		=	'stores/install.rb',

		#other installed files
		File_installed		= {
			:menu			=>	'stores/install/_menu'
		}

		#application file
		File_logic		 	= {
			:routes			=>	'logics/routes.rb'
		}

		#the basic folder
		Folders 			= {
			:app			=>	'logics',
			:tpl			=>	'views',
			:store			=>	'stores',
			:install		=>	'stores/install'
		}

		Folders_others		= {
			:lang			=>	'stores/lang',
			:tool			=>	'tools'
		}

		Paths				= {
			:config_ms		=> 'c:\.Seimtra',
			:config_lx		=> '~/.Seimtra',
			:docs_tpl		=> 'docs/templates',
			:docs_local		=> '/src/seimtra',
			:docs_remote	=> 'https://github.com/coolesting/seimtra-docs.git'
		}

		Root_user 			= {
			:name 			=> 'admin',
			:pawd 			=> 'admin'
		}

		Main_key			= [:primary_key, :index, :foreign_key, :unique]

		Field_type			= {
			:integer		=> 	'integer',
			:string 		=> 	'string',
			:text 			=> 	'text',
			:file			=>	'file',
			:float			=>	'float',
			:datetime		=>	'datetime',
			:date			=>	'date',
			:time			=>	'time',
			:numeric		=>	'numeric',

			:int			=>	'integer',
			:str			=>	'string',
			:dt				=>	'datetime',
			:num			=>	'numeric',
			:pk				=>	'primary_key',
			:fk				=>	'foreign_key',

			:primary_key	=>	'primary_key',
			:foreign_key	=>	'foreign_key',
			:index			=>	'index',
			:unique			=>	'unique'
		}

	end

end

