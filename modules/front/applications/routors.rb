get '/' do
	slim :front
end

get "/set" do
	iset :time_now, Time.now
	@time_now = Time.now
	slim :front
end

get "/get" do
	@time_now = iget :time_now
	slim :front
end
