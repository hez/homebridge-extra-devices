defmodule GenICMP do
  @moduledoc """
  A module for sending Ping packets.

  Pilfered from https://elixirforum.com/t/zing-basic-elixir-icmp-ping-server-using-zig-nif/31681/3
  """
  @data <<0xDEADBEEF::size(32)>>

  @spec ping({integer(), integer(), integer(), integer()}, Keyword.t()) ::
          {:ok, map()} | {:error, any()}
  def ping(addr, opts \\ [])

  def ping({_, _, _, _} = addr, opts) do
    data = @data

    with {:ok, socket} <- open(),
         :ok <- req_echo(socket, addr, data: data),
         {:ok, %{data: ^data}} = resp <- recv_echo(socket, Keyword.get(opts, :timeout, 300)) do
      resp
    else
      {:ok, other} -> {:error, other}
      {:error, :timeout} -> {:error, :timeout}
      _ -> {:error, :invalid_resp}
    end
  end

  @spec ping(String.t(), Keyword.t()) :: {:ok, map()} | {:error, any()}
  def ping(addr, opts) when is_binary(addr) do
    addr |> String.split(".") |> Enum.map(&String.to_integer/1) |> List.to_tuple() |> ping(opts)
  end

  def open, do: :socket.open(:inet, :dgram, :icmp)

  def req_echo(socket, addr, opts \\ []) do
    data = Keyword.get(opts, :data, @data)
    id = Keyword.get(opts, :id, 0)
    seq = Keyword.get(opts, :seq, 0)
    sum = checksum(<<8, 0, 0::size(16), id, seq, data::binary>>)
    msg = <<8, 0, sum::binary, id, seq, data::binary>>

    :socket.sendto(socket, msg, %{family: :inet, port: 1, addr: addr})
  end

  def recv_echo(socket, timeout) do
    with {:ok, <<_::size(160), pong::binary>>} <- :socket.recv(socket, 0, [], timeout),
         <<0, 0, _::size(16), id, seq, data::binary>> <- pong do
      {:ok, %{id: id, seq: seq, data: data}}
    else
      {:error, :timeout} -> {:error, :timeout}
      pong -> {:error, pong}
    end
  end

  defp checksum(bin), do: checksum(bin, 0)

  defp checksum(<<x::integer-size(16), rest::binary>>, sum), do: checksum(rest, sum + x)
  defp checksum(<<x>>, sum), do: checksum(<<>>, sum + x)

  defp checksum(<<>>, sum) do
    <<x::size(16), y::size(16)>> = <<sum::size(32)>>

    res = :erlang.bnot(x + y)

    <<res::big-size(16)>>
  end
end
