## INTRODUCTION

user module


## USAGE

### get user info

the method user_info will return a hash that includes :uid, :name

### user login

	sys_inc(:user_login) to your template

the user whether or not login

	user_login? 'redirect_path'

### user logout

	redirect to path "/user/logout"

or uses method in your code

	user_logout

### add user

	user_add(name, pawd)
