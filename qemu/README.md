# QEMU Support

If you want to build an rpi4 image make sure to use
```
make qemu
```

otherwise the systemd watchdog is going to instantly reset the device.