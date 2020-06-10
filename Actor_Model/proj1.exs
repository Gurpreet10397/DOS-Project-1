defmodule Proj1 do
  use GenServer
  # client side 
  def start_link(input, pid) do
    # second argument is the state (empty list)
    GenServer.start_link(__MODULE__, [input, pid])
  end

  def check_vampire(_server_pid, n, pid) do
    send(self(), {:vamp_check, n, pid})
    # GenServer.call(server_pid, {:vamp_check, n,pid})
  end

  # server side
  def init([input, pid]) do
    # initial state is empty
    # IO.puts "hello server has started"    {:ok, []}
    first = List.first(input)
    last = List.last(input)
    server_pid = self()
    for i <- first..last, i > 0, do: check_vampire(server_pid, i, pid)
    {:ok, nil}
  end

  def handle_info({:vamp_check, n, pid}, vampire_list) do
    # check for odd number of digits
    if rem(length(to_charlist(n)), 2) == 1 do
      {:noreply, vampire_list}
      # for even
    else
      # check for same digits in number and fang pairs
      # check if both fangs don't end in zero
      listDigits = Integer.digits(n)
      listDigits = Enum.sort(listDigits)

      output_fangs =
        Enum.filter(pairs(n), fn {a, b} ->
          fang_number_string = Integer.to_string(a) <> Integer.to_string(b)
          fang_number_int = String.to_integer(fang_number_string, 10)
          fang_number_digits = Integer.digits(fang_number_int)
          fang_number_digits = Enum.sort(fang_number_digits)

          length(to_charlist(a)) == length(to_charlist(n)) / 2 &&
            length(to_charlist(b)) == length(to_charlist(n)) / 2 &&
            validate_both_fangs_dont_end_with_zero(a, b) &&
            fang_number_digits == listDigits
        end)

      if !Enum.any?(output_fangs) do
        {:noreply, vampire_list}
      else
        output_fangs_list = Enum.flat_map(output_fangs, fn {x, y} -> [x, y] end)
        # output_fangs_string = Enum.join(output_fangs_list, " ")
        reply = [n | output_fangs_list]
        Printer.p_cast(pid, Enum.join(reply, " "))
        {:noreply, [reply | vampire_list]}
      end
    end
  end

  # These two functions are not used by the genserver, but are locally used by :vamp_check(Proj1.check_vampire) function of GenServer
  def pairs(n) do
    num1 = trunc(n / :math.pow(10, div(length(to_charlist(n)), 2)))
    num2 = :math.sqrt(n) |> round
    for i <- num1..num2, rem(n, i) == 0, do: {i, div(n, i)}
  end

  def validate_both_fangs_dont_end_with_zero(fang1, fang2) do
    if rem(fang1, 10) == rem(fang2, 10) && rem(fang1, 10) == 0 do
    else
      [{fang1, fang2}]
    end
  end
end

defmodule Printer do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init([]) do
    {:ok, []}
  end

  def p_cast(pid, reply) do
    GenServer.cast(pid, {:v_print, reply})
  end

  def p_call(pid) do
    GenServer.call(pid, :vamp_print)
  end

  def handle_cast({:v_print, reply}, state) do
    {:noreply, [reply | state]}
  end

  def handle_call(:vamp_print, _from, state) do
    {:reply, state, state}
  end
end

defmodule VamSupervisor do
  use Supervisor

  def start_link([lower_bound, upper_bound, pid]) do
    Supervisor.start_link(__MODULE__, [lower_bound, upper_bound, pid], [])
  end

  def init([lower_bound, upper_bound, pid]) do
    list = for i <- lower_bound..upper_bound, i > 0, do: i * 1

    cond do
      (upper_bound - lower_bound) > 10000000 ->
        list1 = Enum.chunk_every(list, 100000)
        children = Enum.map(list1, fn n -> worker(Proj1, [n, pid], id: List.first(n)) end)
        supervise(children, strategy: :one_for_one)

      (upper_bound - lower_bound) > 100000 ->
        list1 = Enum.chunk_every(list, 25000)
        children = Enum.map(list1, fn n -> worker(Proj1, [n, pid], id: List.first(n)) end)
        supervise(children, strategy: :one_for_one)
        
      (upper_bound - lower_bound) > 10000 ->
        list1 = Enum.chunk_every(list, 10000)
        children = Enum.map(list1, fn n -> worker(Proj1, [n, pid], id: List.first(n)) end)
        supervise(children, strategy: :one_for_one)

      (upper_bound - lower_bound) < 10000 ->
        list1 = Enum.chunk_every(list, 1000)
        children = Enum.map(list1, fn n -> worker(Proj1, [n, pid], id: List.first(n)) end)
        supervise(children, strategy: :one_for_one)
    end
  end
end

arguments = Enum.to_list(System.argv())
lower_bound = String.to_integer(Enum.at(arguments, 0), 10)
upper_bound = String.to_integer(Enum.at(arguments, 1), 10)
{:ok, pid} = Printer.start_link([])
VamSupervisor.start_link([lower_bound, upper_bound, pid])

  cond do
    (upper_bound - lower_bound) < 10000 ->
      :timer.sleep(20)
   (upper_bound - lower_bound) >= 100_000 ->
   :timer.sleep(1000)

   (upper_bound - lower_bound) > 500000 ->
    :timer.sleep(3000)
    
   (upper_bound - lower_bound) >= 1_000_000 ->
    :timer.sleep(60000) #1 min

    (upper_bound - lower_bound) > 100_000_000 ->
      :timer.sleep(120000) #2min
    end

Enum.each(Printer.p_call(pid), fn y -> IO.puts(y) end)