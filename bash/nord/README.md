# NordVPN

These scripts are meant to easily set up NordVPN as a peer or an  
exit node.

The following commands are supplied:

- login.sh
- logout.sh
- config.sh
- connect.sh
- list_connected
- exit-node.sh
- status.sh


## Peer names

mesh-hp
mesh-dell
mesh-tab8
mesh-pixel
mesh-raspberry
mesh-sunndal

## Scripts

### config.sh

``` bash
./bash/nord/config.sh <<mesh-nickname>>
```

### connect.sh
``` bash
./bash/nord/exit_node.sh <<mesh-nickname>>
```

### connect.sh
``` bash
./bash/nord/exit_node.sh <<mesh-nickname>>
```
### connect.sh
``` bash
./bash/nord/exit_node.sh <<mesh-nickname>>
```
### connect.sh
``` bash
./bash/nord/exit_node.sh <<mesh-nickname>>
```
### connect.sh
``` bash
./bash/nord/exit_node.sh <<mesh-nickname>>
```

## RaspberryPi routing

The Raspberry Pi will be configured to be used as an exit-node for
other meshnet peers. Other peers using the Raspberry Pi for routing
also gives them permission to access local devices like printers,
cameras and other LAN connected devices.

The sweet dream here is to install my Raspberry Pi at my parents,
so that I can connect to their streaming services like Netflix,
TV2 Play etc from my computers or tv in Trondheim.

The catch is; The Raspberry Pi can not be running NordVPN. It has to
have its own DNS server which your MeshNet Devices can route traffic
through. Possible solutions:

- Maybe add an External Device?
