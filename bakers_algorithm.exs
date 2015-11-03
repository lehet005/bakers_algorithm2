defmodule Fib do
	def fib(0) do 0 end
	def fib(1) do 1 end
	def fib(n) do fib(n-1) + fib(n-2) end
end

defmodule Manager do
	def manage([],[]) do
		receive do
			{:add_customer, PID} -> manage([PID],[])
			{:add_server, PID} -> manage([],[PID])
		end
	end

defmodule Customer do
  def start do
    zzz = :random.uniform(1000)
    :timer.sleep(zzz)
    customer = spawn(&__MODULE__.loop/0)
    send(customer, {:wake_up})
  end
  def loop do
    receive do
      {:wake_up} ->
        send(:manager, {:add_customer, self()})
        loop
      {:fib_result, result} ->
        IO.puts("Fib result: #{result} for #{inspect self()}")
      {:fib, sender} ->
        :random.seed(:os.timestamp)
        fib = (:random.uniform(5) + 10)
	IO.puts("Random fib: #{fib}")
        send(sender, {:fib, self(), fib})
        loop
    end
  end

end

defmodule Server do
  def start do
    server = spawn(&__MODULE__.loop/0)
    send(:manager, {:add_server, server})
  end
  def loop do
    receive do
      {:compute_fib, customer, fib} ->
        send(customer, {:fib_result, Fib.fib(fib)})
        send(:manager, {:add_server, self()})
        loop
    end
  end
end

