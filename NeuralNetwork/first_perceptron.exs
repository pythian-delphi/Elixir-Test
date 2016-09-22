defmodule Ann do
  def sigmoid(x) do
    1.0 / (1.0 + :math.exp(-x) )
  end

  def dot_prod([], []), do: 0
  def dot_prod([x_head | x_tail], [y_head | y_tail]), do: x_head * y_head + dot_prod(x_tail, y_tail)

  def feed_forward(weights, inputs) do
    sigmoid(dot_prod(weights, inputs))
  end

  def perceptron(weights, inputs, output_PIDs) do
    IO.puts inspect weights
    IO.puts inspect inputs
    IO.puts output_PIDs
    IO.puts ""
    receive do
      { :stimulate, input } ->
        IO.puts inspect input
        IO.puts inspect inputs
        new_inputs = replace_input(inputs, input)
        IO.puts inspect new_inputs
        cvtList = convert_to_list(new_inputs)
        IO.puts inspect cvtList
        IO.puts inspect weights
        output = feed_forward(weights, cvtList)
        IO.puts inspect output

        if output_PIDs != [] do
          List.foreach(
          fn(output_PID) ->
            send output_PID, { :stimulate, [self, output]}
          end,
          output_PIDs
            )
        end

        if output_PIDs == [] do
          #io.format("~n~w outputs: ~w", [self, output])
          IO.puts inspect [self, output]
        end
        perceptron(weights, new_inputs, output_PIDs)
    end
  end

  def replace_input(inputs, input) do
    IO.puts inspect input
    {input_PIDs, _} = input
    IO.puts inspect input_PIDs
    #List.keyreplace(input_PIDs, 1, inputs, input)
    List.keyreplace(inputs, input_PIDs, 0, input)
  end

  def convert_to_list(inputs) do
    #List.map(
    Enum.map(inputs,
    fn tup ->
      {_, val} = tup
      val
    end
    )
  end
end


pid = spawn(Ann, :perceptron, [[0.5, 0.2], [{1, 0.6}, {2, 0.9}], []])
send pid, { :stimulate, {1, 0.3} }
