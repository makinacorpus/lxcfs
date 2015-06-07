Notes
=======
```
sudo apt-get install dh-systemd  bzr python-paramiko dh-autoreconf pbuilder build-essential
```

cat ~/.dput.cf
```
[lxc]
fqdn = ppa.launchpad.net
method = sftp
incoming = ~makinacorpus/lxc
login = kiorky
allow_unsigned_uploads = 0
```
# MERGE UPSTREAM
git remote rm o
git remote add o https://github.com/lxc/lxcfs.git
git fetch --all
git rebase -i o/master
./mc_packages/sync_debian.sh


Packaging (/debian) is the last DSC for lxc ppa (no vivid package for a long time)
