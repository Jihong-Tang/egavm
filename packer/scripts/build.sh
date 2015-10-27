#!/usr/bin/env bash

# base
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo  ALL=(ALL:ALL) ALL/%sudo  ALL=NOPASSWD:ALL/g' /etc/sudoers

echo "UseDNS no" >> /etc/ssh/sshd_config

# vagrant user
date > /etc/vagrant_box_build_time

mkdir /home/vagrant/.ssh
wget --no-check-certificate \
    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Fix stdin not being a tty
if grep -q -E "^mesg n$" /root/.profile && sed -i "s/^mesg n$/tty -s \\&\\& mesg n/g" /root/.profile; then
    echo "==> Fixed stdin not being a tty."
fi

echo "==> Install VirtualBox guest additions"
#apt-get install -y virtualbox-guest-utils virtualbox-guest-additions-iso

m-a prepare

# Packer will automatically download the proper guest additions.
cd $HOME
mount VBoxGuestAdditions.iso -o loop /mnt
echo "yes" | sh /mnt/VBoxLinuxAdditions.run --nox11 # type yes

/etc/init.d/vboxadd setup
update-rc.d vboxadd defaults

rm $HOME/VBoxGuestAdditions.iso

echo "==> Check that Guest Editions are installed"
lsmod | grep vboxguest

# cleanup
apt-get -y autoremove
apt-get -y clean

echo "==> Cleaning up dhcp leases"
rm /var/lib/dhcp/*

echo "==> Cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "==> Zero disk"
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
