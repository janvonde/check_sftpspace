# check_sftpspace
 
This is a monitoring plugin for [icinga](https://www.icinga.com) to check the free space on a sftp share.

It was initially developed by [intranda GmbH](http://www.intranda.com).


### Requirements
This script requires a working key authentication without password to the sftp host. You can set it up like this:

```
ssh-keygen -t rsa
ssh-keygen -e -f ~/.ssh/id_rsa.pub | grep -v "Comment:" > ~/.ssh/id_rsa_rfc.pub
cat ~/.ssh/id_rsa_rfc.pub >> backup_authorized_keys
echo mkdir .ssh | sftp USER@HOST
scp backup_authorized_keys USER@HOST:.ssh/authorized_keys
```
See also: http://wiki.hetzner.de/index.php/Backup_Space_SSH_Keys



### Usage
Try the plugin at the command line like this:
```
./check_sftpsace.sh -h [host] -u [user] -w [warn] -c [crit]
```

Replace the variables:
* __host__: sftp host to connect to
* __user__: username at the sftp server
* __warn__: percentage of needed minimum free space before warning
* __crit__: percentage of needed minimum free space before critical



You can define the icinga2 check command as follows:
```
/* Define check command for check_sftpspace */
object CheckCommand "sftpspace" {
  import "plugin-check-command"
  command = [ PluginDir + "/check_sftpspace.sh" ]

  arguments = {
    "-h" = {
      "required" = true
      "value" = "$ss_host$"
    }
    "-u" = {
      "required" = true
      "value" = "$ss_user$"
    }
    "-w" = {
      "required" = true
      "value" = "$ss_warn$"
    }
    "-c" = {
      "required" = true
      "value" = "$ss_crit$"
    }
  }

  vars.ss_warn = 30
  vars.ss_crit = 10

}
```
### License
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.

