<div align="center">
<img src="images/logo.png">
<h1>Nxgipd2mqtt Hass.io Add-on</h1>
<div style="display: flex; justify-content: center;">
  <a style="margin-right: 0.5rem;" href="https://dev.azure.com/orgjvr/hassio-nxgipd2mqtt/_build?definitionId=1&_a=summary">
    <img src="https://img.shields.io/azure-devops/build/orgjvr/fdcd83e4-a36e-473f-80f8-6a1bd49fdb3a/1?label=build&logo=azure-pipelines&style=flat-square">
  </a>
  <a style="margin-left: 0.5rem;" href="https://cloud.docker.com/u/orgjvr/repository/docker/orgjvr/nxgipd2mqtt-armhf">
    <img src="https://img.shields.io/docker/pulls/orgjvr/nxgipd2mqtt-armhf.svg?style=flat-square&logo=docker">
  </a>
</div>
<br>
<p>Run <a href="https://github.com/tjko/nxgipd">nxgipd</a> as a Hass.io Add-on with MQTT communication</p>
</div>


## Installation

Add the repository URL under **Supervisor (Hass.io) → Add-on Store** in your Home Assistant front-end:

    https://github.com/orgjvr/hassio-nxgipd2mqtt

The repository includes one add-on:

- **nxgipd2mqtt** is a stable release that tracks the released versions of nxgipd2mqtt.

## Configuration

Configure the add-on via your Home Assistant front-end under **Supervisor (Hass.io) → Dashboard → nxgipd2mqtt**.

The configuration closely mirrors that of [nxgipd itself](https://github.com/tjko/nxgipd), with a couple of key differences:

1. Hass.io requires add-on configuration in JSON format, rather than XML. 

2. An additional top-level `data_path` option is required which defaults to `/share/nxgipd2mqtt`. This is the path where the add-on should persist the data. The path must be relative to the Home Assistant shared data directory (which is `/usr/share/hassio` for Hass.io). Note that both `config` and `share` directories are mapped into the container (read-write) and are available to you.



### Serial Port Setting

To find out which serial ports are available to the add-ons, go to **Supervisor (Hass.io) → System → Host system** and click on the "Hardware" button. The default value is `/dev/ttyACM0`.

### MQTT Settings

Depending on your configuration, the MQTT server config may need to include the port, typically `1883` or `8883` for SSL communications. For example, `mqtt://core-mosquitto:1883` for [Hass.io's Mosquitto addon](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md).

Ensure the user credentials specified under the `mqtt` section (`user` and `password`) are correct and have write access to the MQTT server. Additional [configuration is required](https://github.com/home-assistant/hassio-addons/tree/master/mosquitto#known-issues-and-limitations) when the `anonymous` option is enabled in the [Hass.io's Mosquitto addon](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md).


---
### Updating the Add-on 

The stable, versioned nxgipd2mqtt can be updated using the standard Hass.io update functionality within the user interface. This add-on will be updated with bug fixes and as the underlying `nxgipd2mqtt` library is updated.

----
### Socat

In some cases it is not possible to forward a serial device to the container that zigbee2mqtt runs in. This could be because the device is not physically connected to the machine at all. 

Socat can be used to forward a serial device over TCP to zigbee2mqtt. See the [socat man pages](https://linux.die.net/man/1/socat) for more info.

You can configure the socat module within the socat section using the following options:

- `enabled` true/false to enable socat (default: false)
- `master` master or first address used in socat command line (mandatory)
- `slave` slave or second address used in socat command line (mandatory)
- `options` extra options added to the socat command line (optional)
- `log` true/false if to log the socat stdout/stderr to data_path/socat.log (default: false)
- `initialdelay` delay (in seconds) to wait when the plugin is started before zigbee2mqtt is started (optional)
- `restartdelay` delay (in seconds) to wait before a socat process is restarted when it has terminated (optional)

**NOTE:** You'll have to change both the `master` and the `slave` options according to your needs. The defaults values will make sure that socat listens on port `8485` and redirects its output to the config setting `SerialDevice`. Previously it defaulted to `/dev/ttyN2M`, but after a recent docker update I got a read-only `/dev` which was easiest to fix by moving the serial device to `/ttyN2M`. 

----
### Issues

If you find any issues with the addon, please check the [issue tracker](https://github.com/orgjvr/hassio-nxgipd2mqtt/issues) for similar issues before creating one. If your issue is regarding specific devices or, more generally, an issue that arises after nxgipd2mqtt has successfully started, it should likely be reported in the [nxgipd issue tracker](https://github.com/tjko/nxgipd/issues)

Feel free to create a PR for fixes and enhancements. 

## Credits
- [Org](https://github.com/orgjvr) for the conversion to an Hass.io addon and the mqtt communication
- [Timo](https://github.com/tjko) for the interface program [nxgipd](https://github.com/tjko/nxgipd)
- [danielwelch](https://github.com/danielwelch) for the framework of the addon [zigbee2mqtt](https://github.com/danielwelch/hassio-zigbee2mqtt)
