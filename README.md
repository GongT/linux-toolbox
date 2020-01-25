# Install
```bash
cd /path/you/like
git clone https://github.com/GongT/linux-toolbox.git
cd linux-toolbox
sudo bash ./install_environment.sh
```

Will load in new interactive BASH session.

### Uninstall
```bash
rm -f /etc/profile.d/01-linux-toolbox.sh
rm -f /etc/profile.d/00-environment.sh
rm -rf /path/to/cloned/repo
```

# Commands
* alias:
  * `systemctl` & `journalctl` & `networkctl` | `service` with sudo
  * `dnf` | `yum` | `apt` with sudo
  * `suvi`: sudo vim
  * `vi`: vim
  * `gitsub`: git submodule foreach git
  * `ls`, `l.`, `ll`, `la`: some list helper
* environment variables:
  * `$SSH_CLIENT_IP` if ssh
  * `$DISPLAY` if ssh *(=$SSH_CLIENT_IP:0)*
* commands:
  * `auto_ssh`: unsafe set password in ssh commandline
  * `center`: `echo` align center
  * `cleanup-shell`: kill all child process of current bash
  * `command_exists`: test if a command is exists or not
  * `cru`: modify crontab
  * `efi-install-grub2`: (re-)install grub2
  * `efi-update-grup2`: update grub2 menu config
  * `file-colors`: explain current `$LS_COLORS`
  * `flush-kernal-cache`: write kernel file cache into disk
  * `gits`: control all git repos in current directory (but not recursive)
  * `hostsfile`: display or modify /etc/hosts
  * `ip-ban`: (un-)ban ip with iptables
  * `is-root`: return 0 if uid==0
  * `is-ssh`: return 0 if from ssh
  * `lnall`: create symlink of all files in a folder
  * `lscolor`: print shell 256 color table
  * `lscolor8`: print shell ansi color table
  * `lsrpm`: list all installed rpms
  * `remove-eta`: remove `eta(英国中部时间)` from yum on centos
  * `reperm`: recursive chmod all files in current folder, folder set to 0755, file set to 0644 *(or 0755 by -x)*
  * `scsi-rescan`: trigger rescan SATA devices
  * `ssh-client-ip`: print ssh client ip, empty if not from ssh
  * `sysinstall`: call system package manager with `install -y $@`
  * `utf8`: return 0 if `$LANG` shows the terminal support display utf8
  * `wget-cookie`: wget with save cookie option
  * `who-am-i`: show terminal device of this shell
* application related commands: (no such command if relate app did not installed)
  * `dnf`:
    * `dnf i`: dnf install -y ...
    * `dnf s`: dnf list arg1\* arg2\* ...
    * `dnf p`: dnf provides */bin/xxx /usr/lib64/yyy.so.1
  * `docker`
    * `dpss`: short `docker ps`
    * `dps`: shortest `docker ps`
    * `dmg`: short `docker image`
  * `journalctl`:
    * `logcat`: show newest 9000 log lines of services
    * `logtail`: realtime follow log output of services
  * `node.js`:
    * `update-nodejs`: update latest (not LTS) nodejs into /usr/nodejs
* source commands:
  * `path-var`: display or modify "$PATH"
  * `proxy`: handle HTTP_PROXY related thing
  * `set-prompt`: set shell prompt string
  * `set-window-title`: set terminal window title
  * `set-window-title-callback`: set a command to generate window title *(run before everytime bash print prompt)*
  * `docker clean`: remove stopped containers, delete images without tag

