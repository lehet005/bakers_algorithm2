defmodule Fib do
	def fib(0) do 0 end
	def fib(1) do 1 end
	def fib(n) do fib(n-1) + fib(n-2) end
end

defmodule Init do
	def init(num_servers) do
		manager = spawn(fn -> Manager.manage([],[]) end)
		Process.register(manager, :prime_manager)
		IO.puts("Starting Manager, adding ${num_servers} servers.")
		Enum.map 0..num_servers-1, &(dumb_server_spawn_hack(&1))
		
	end 

	def add_customers(num_customers) do
		Enum.map 0..num_customers-1, &(dumb_customer_spawn_hack(&1))
		
	end

	def add_servers(num_servers) do
		Enum.map 0..num_servers-1, &(dumb_server_spawn_hack(&1))
		
	end

	def dumb_customer_spawn_hack(x) do
		Customer.start()
	end 
		
	def dumb_server_spawn_hack(x) do
		Server.start()
	end 
end


defmodule Manager do
	def manage(customers, servers) do
		IO.puts("Manager")
		if (customers !== [] and servers !== []) do 
			[a_customer | rest_customers] = customers
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
    		zzz = :random.uniform(2000)
    		:timer.sleep(zzz)
    		customer = spawn(&__MODULE__.loop/0)
    		send(customer, {:wake_up})
		#IO.puts("Customer lives.")
  	end
  	def loop do
    		receive do
      			{:wake_up} ->
        			send(:prime_manager, {:add_customer, self()})
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
				send(:prime_manager, {:done, self()})
				loop
      			{:compute_fib, customer, fib} ->
				IO.puts("Server recieves fib request")
        			send(customer, {:fib_result, Fib.fib(fib)})
        			send(:prime_manager, {:done, self()})
        			loop
    		end
  	end
end

