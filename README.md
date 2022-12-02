# Activu AIS Connect

Use this plugin to connect to and control Activu Vis|Abiilty System via Activu Interface Server (AIS).

## Prerequisites

Before you can configure the plugin, ensure that Vis|Ability is configuredand reachable on your network. Also ensure that AIS installed and configured. QSC recommends that you configure a static IP address for the device, as DHCP addresses can change.

Refer to the Activu SDK Guide for help with setting up and connecting to AIS.

## Connecting to the Device
To begin using the plugin, drag it into the schematic and configure its Properties. Then, press F5 to save your design to the Core and run it.

In the plugin's Setup tab:

Type the IP Address of the device.

Type the Port Number of the device.
Default: 59095

Specify your AIS Username and Password credentials for the device, and then press Enter.
  
The plugin will automatically attempt a connection. If you see "OK" status, you are successfully connected to the device. If you see a "Fault" error, check to make sure you entered the correct parameters.

## Properties
#### Connection Test Interval
Set the amount of time, in minutes, between login status checks with the AIS. (Default 5 minutes)

#### Show Debug
Select 'Yes' to show the Debug Output window. For details, see the Debug Output topic in the Q-SYS Help.

## Controls
### Setup
#### IP Address
The IP address of AIS

#### Username
This is the same username as for the device's configurator.

#### Password
This is the same password as for the device's configurator.

#### Status
Displays the current connection status.

#### Disabled
Logs out of, and disables the connection with AIS.

## Support

If you have any questions or concerns with this template, please contact tyler.danielson@activu.com
