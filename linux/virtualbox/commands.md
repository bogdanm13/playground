## Commands

### Uninstall an extension pack

```
[root@localhost bmarincas]# VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"        
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Successfully uninstalled "Oracle VM VirtualBox Extension Pack".
```

### Install an extension pack

```
[root@localhost bmarincas]# VBoxManage extpack install .VirtualBox/Oracle_VM_VirtualBox_Extension_Pack-5.1.18.vbox-extpack
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
Successfully installed "Oracle VM VirtualBox Extension Pack".
```

## Start time sync
```
VBoxManage guestproperty set "win7pccoe" "/VirtualBox/GuestAdd/VBoxService/--timesync-set-start"
```

