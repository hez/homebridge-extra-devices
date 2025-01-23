defmodule HomebridgeExtraDevices.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: HomebridgeExtraDevices.TaskSupervisor},
      HomebridgeExtraDevices.HAP.Computer,
      HomebridgeExtraDevices.HAP.HDMICEC,
      {HomebridgeExtraDevices.TV, false},
      {HAP,
       %HAP.AccessoryServer{
         name: "Homebride Extra Devices",
         model: "unknown",
         identifier: "11:22:33:44:12:89",
         accessory_type: 7,
         accessories: [
           %HAP.Accessory{
             name: "HDMI TV",
             services: [
               %HAP.Services.Outlet{
                 name: "HDMI TV",
                 on: {HomebridgeExtraDevices.HAP.HDMICEC, :on},
                 outlet_in_use: {HomebridgeExtraDevices.HAP.HDMICEC, :outlet_in_use}
               }
             ]
           },
           %HAP.Accessory{
             name: "Computer",
             services: [
               %HAP.Services.Switch{
                 name: "Gaming Computer",
                 on: {HomebridgeExtraDevices.HAP.Computer, :on}
               }
             ]
           }
         ]
       }}
    ]

    Logger.add_handlers(:homebridge_extra_devices)
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomebridgeExtraDevices.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
