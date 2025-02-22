# SATOS Changelog
## version 1.0 (reliable Iridium packet Sniffing)
- watchdog (reboot when no server-connection) (via client)
- default plug&play ethernet config with dhcp

## Planned
### version 1.1
- FixedJobs-handling (client.pkg.task.backend.rest.go): deliver more details in the job-status. Has to be compartible with website!
- website: show position of sensors on world-map, show online-history of a sensor
### further versions
- upload new network-config: public-key infrastructure for every sensor. Sensor delivers public key in status-message (website compatibility!). User can upload "private-file", sensor is downloading it.
- over-the-air updates
- open platform to other tasks (e.g. for Oxford)
- make use of different Antennas
