defmodule Fib do
	def fib(0) do 0 end
	def fib(1) do 1 end
	def fib(n) do fib(n-1) + fib(n-2) end
end

defmodule Init do
	def start() do #num_customers, num_servers
		manager = spawn(fn -> Manager.manage([],[]) end)
		Process.register(manager, :prime_manager)
		Customer.start()
		Customer.start()
		Customer.start()
		Customer.start()
		Customer.start()
		Server.start()
		Server.start()
		Server.start()
		Server.start()
		
		##Make list of servers
		##Start manager
		##call manage([], servers)
		##Make list of customer
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
    		zzz = :random.uniform(1000)
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
        			fib = (:random.uniform(10))
				IO.puts("Random fib: #{fib}")
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

