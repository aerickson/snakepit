#!/usr/bin/env bash
set -e

aptget() {
    DEBIAN_FRONTEND=noninteractive apt-get -yq "$@"
}

print_header () {
    printf "\n>>>>>>>> $1 <<<<<<<<\n\n"
}

print_header "Installing dependencies"
aptget update
aptget install openssh-server vim iputils-ping

print_header "Creating worker user and directory"
useradd -m -s /usr/sbin/nologin -u 2525 worker
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo "worker:${password}" | chpasswd
mkdir -p /data

print_header "Configuring ssh-daemon"
mv /root/sshd_config /etc/ssh/sshd_config

print_header "Creating default pit info file"
echo 'PIT_DAEMON_HOST="snakepit-daemon.lxd"' >>/etc/pit_info

print_header "Installing daemon service"
mv snakepit.service /lib/systemd/system/
systemctl enable snakepit