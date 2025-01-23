defmodule HomebridgeExtraDevices.HAP.Computer do
  @moduledoc """
  Responsible for representing a HAP Switch
  """

  @behaviour HAP.ValueStore

  use GenServer

  require Logger

  def start_link(config),
    do: GenServer.start_link(__MODULE__, config, name: __MODULE__)

  @impl HAP.ValueStore
  def get_value(:on) do
    case GenICMP.ping(ip_address()) do
      {:ok, resp} ->
        Logger.debug("got resp #{inspect(resp)}")
        {:ok, true}

      err ->
        Logger.debug("got unknown value #{inspect(err)}")
        {:ok, false}
    end
  end

  def get_value(val), do: Logger.error("unknown get #{inspect(val)}")

  @impl HAP.ValueStore
  def put_value(0, :on), do: put_value(false, :on)
  def put_value(1, :on), do: put_value(true, :on)

  def put_value(false, :on) do
    Logger.warning("unsupported off option")
    :ok
  end

  def put_value(true, :on), do: WOL.send(mac_address())

  def put_value(value, opts),
    do: Logger.error("unknown put #{inspect(value)} and #{inspect(opts)}")

  @impl HAP.ValueStore
  def set_change_token(change_token, name),
    do: GenServer.call(__MODULE__, {:set_change_token, change_token, name})

  @impl GenServer
  def init(_), do: {:ok, %{change_tokens: %{on: nil, outlet_in_use: nil}}}

  @impl GenServer
  def handle_call({:put, :on, _value} = params, _from, state) do
    Logger.info("HAP.value_changed/1 called because #{inspect(params)}")
    HAP.value_changed(state.change_tokens.on)
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:set_change_token, change_token, name}, _from, state) do
    Logger.info("new change token for #{inspect(name)} #{inspect(change_token)}")
    {:reply, :ok, %{state | change_tokens: Map.put(state.change_tokens, name, change_token)}}
  end

  def ip_address,
    do: Application.get_env(:homebridge_extra_devices, HAP.Computer) |> Keyword.get(:ip_address)

  def mac_address,
    do: Application.get_env(:homebridge_extra_devices, HAP.Computer) |> Keyword.get(:mac_address)
end
