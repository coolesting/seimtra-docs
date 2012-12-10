## INTRODUCTION

user module


## USAGE

### get user info

the method user_info will return a hash that includes :uid, :name

### user login

put the code to your template

	== sys_inc(:user_login)

the user whether or not login using method

	user_login? 'redirect_path'

### user logout

	redirect to path "/user/logout" in template

or use the method in your code

	user_logout

### add user

	user_add(name, pawd)
