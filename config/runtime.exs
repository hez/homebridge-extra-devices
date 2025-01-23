import Config

config :homebridge_extra_devices, HAP.Computer,
  mac_address: System.get_env("MAC_ADDRESS"),
  ip_address: System.get_env("IP_ADDRESS")

config :homebridge_extra_devices, HAP.TV, cec_address: System.get_env("CEC_ADDRESS")
