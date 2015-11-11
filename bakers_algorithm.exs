defmodule Fib do
	def fib(0) do 0 end
	def fib(1) do 1 end
	def fib(n) do fib(n-1) + fib(n-2) end
end
#A horrible experiment in elixir
#Henry Fellows, Peter Hanson, and Mark Lehet

#Commands:
##Terminal 1##
#$ iex --sname a --cookie pass bakers_algorithm.exs
##Terminal 2##
#$ iex --sname b --cookie pass bakers_algorithm.exs
#> Node.connect([:a@host-name])
#> Init.init([:a@host-name, :b@host-name], 5)
#> Init.add_c([:a@host-name, :b@host-name], 20)

defmodule Init do
	def init(host_list, num_servers) do
		manager = spawn(fn -> Manager.manage([],[]) end)
		:global.register_name(:prime_manager, manager)
		IO.puts("Starting Manager, adding #{num_servers} servers.")
		add_s(host_list, num_servers)

	end

	#Adds customers dynamically.
	##basically, we couldn't find a repeat, so we use a map to do something repeatedly

	def add_c(host_list, num_customers) do
		Enum.map 0..num_customers-1, &(customer_spawn_hack(host_list, &1))
	end

	#Adds servers dynamically.
	##basically, we couldn't find a repeat, so we use a map to do something repeatedly
	def add_s(host_list, num_servers) do
		Enum.map 0..num_servers-1, &(server_spawn_hack(host_list, &1))
	end

	def customer_spawn_hack(host_list, x) do
		host_num = :random.uniform(Enum.count(host_list)) - 1
		host = Enum.at(host_list, host_num,0)
		Node.spawn(host, Customer, :start, [])
	end

	def dumb_server_spawn_hack(host_list, x) do
		host_num = :random.uniform(Enum.count(host_list)) - 1
		host = Enum.at(host_list, host_num, 0)
		Node.spawn(host, Server, :start, [])
	end

#This is a simple module example... for testing purposes
defmodule Geometry do
  def area_loop do
    receive do
      {:rectangle, w, h} ->
        IO.puts("Area = #{w * h}")
        area_loop()
      {:circle, r} ->
        IO.puts("Area = #{3.14 * r * r}")
        area_loop()
    end
  end
endst, host_num, 0)
		Node.spawn(host, Customer, :start, [])
	end

	def server_spawn_hack(host_list, x) do
		host_num = :random.uniform(Enum.count(host_list)) - 1
		host = Enum.at(host_list, host_num, 0)
		Node.spawn(host, Server, :start, [])
	end
end

defmodule Manager do
	def manage(customers, servers) do
		IO.puts("Manager")
		if (customers !== [] and servers !== []) do
			[a_customer | restname(:prime_manager, manager)_customers] = customers
			[a_server | rest_servers] = servers
			send(a_customer, {:server, a_server})
			manage(rest_customers, rest_servers)
		else
			IO.puts("Manager moves to recieve block")
			receive do
				{:add_customer, idnum} ->
					IO.puts("Manager successfully recieved customer.")
					manage((customers ++ [idnum]),servers)
				{:done, idnum} ->
					IO.puts("Manager successfully recieved server.")
					manage(customers,(servers ++ [idnum]))
			end
		end
	end
end

defmodule Customer do
  	def start do
    		:timer.sleep(:random.uniform(2000))
    		customer = spawn(&__MODULE__.loop/0)
    		send(customer, {:wake_up})
		#IO.puts("Customer lives.")
  	end
  	def loop do
    		receive do
      			{:wake_up} ->
        			send(:global.whereis_name(:prime_manager), {:add_customer, self()})
        			loop
      			{:fib_result, result} ->
        			IO.puts("Fib result: #{result}")
      			{:server, server} ->
        			:random.seed(:os.timestamp)
        			fib = (:random.uniform(5) + 30)
        			send(server, {:compute_fib, self(), fib})
        			loop
		end
	end
end

defmodule Server do
 	def start do
		IO.puts("Server lives.")
    		server = spawn(&__MODULE__.loop/0)
   	 	send(server, {:wake_up})
  	end
  	def loop do
    		receive do
			{:wake_up} ->
				send(:global.whereis_name(:prime_manager), {:done, self()})
				loop
      			{:compute_fib, customer, fib} ->
				IO.puts("Server recieves fib request")
        			send(customer, {:fib_result, Fib.fib(fib)})
        			send(:global.whereis_name(:prime_manager), {:done, self()})
        			loop
    		end
  	end
end
