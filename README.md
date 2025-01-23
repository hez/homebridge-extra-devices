# HDMIHAPAccessory

Combines the HDMI HAP switch and the WOL HAP switch.

## Building

- `MIX_ENV=prod mix build`
- Restart service `sudo systemctl restart homebridge_extra_devices.service`

### Configure

#### Application config

add your MAC and IPC addresses to `bin/config.sh`.

```bash
export MAC_ADDRESS="xx:xx:xx:xx:xx:xx"
export IP_ADDRESS="xxx.xxx.xxx.xxx"
export SECRET_KEY_BASE=xxx
export CEC_ADDRESS="0.0.0.0"
```

### Installing service

- Copy service to systemd directory `sudo cp homebridge_extra_devices.service /lib/systemd/system/`
- Restart systemd `sudo systemctl daemon-reload`
- Enable service `sudo systemctl enable homebridge_extra_devices.service`
- And reboot

### Getting the HAP pairing code again

```elixir
HAP.Display.update_pairing_info_display()
```
