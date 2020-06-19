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

    https://github.com/orgjvr/hassio-orgjvr2mqtt

Click on Nxgipd2mqtt under the new repository and click on Install.


## Configuration

Configure the add-on via your Home Assistant front-end under **Supervisor (Hass.io) → Dashboard → nxgipd2mqtt**.

The configuration closely mirrors that of [nxgipd itself](https://github.com/tjko/nxgipd), with a couple of key differences:

1. Hass.io requires add-on configuration in JSON format, rather than XML. 

2. An additional top-level `data_path` option is required which defaults to `/share/nxgipd2mqtt`. This is the path where the add-on should persist the data. The path must be relative to the Home Assistant shared data directory (which is `/usr/share/hassio` for Hass.io). Note that both `config` and `share` directories are mapped into the container (read-write) and are available to you.


### Serial Port Setting

To find out which serial ports are available to the add-ons, go to **Supervisor (Hass.io) → System → Host system** and click on the "Hardware" button. 

### MQTT Settings

Depending on your configuration, the MQTT server config may need to include the port, typically `1883` or `8883` for SSL communications. For example, `mqtt://core-mosquitto:1883` for [Hass.io's Mosquitto addon](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md).

Ensure the user credentials specified under the `mqtt` section (`user` and `password`) are correct and have write access to the MQTT server. Additional [configuration is required](https://github.com/home-assistant/hassio-addons/tree/master/mosquitto#known-issues-and-limitations) when the `anonymous` option is enabled in the [Hass.io's Mosquitto addon](https://github.com/home-assistant/hassio-addons/blob/master/mosquitto/README.md).




