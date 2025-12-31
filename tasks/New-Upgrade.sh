#!/usr/bin/env bash

PKGS=(
  "leapp*"
  "elevate-release"
  "epel-release"
  "rpmconf"
  "yum-utils"
  "iptables-ebtables"
  "make-devel"
)

for pkg in "${PKGS[@]}"; do
    if rpm -qa | grep -i "$pkg" &> /dev/null; then
        echo "Removing $pkg"
        sudo dnf -y remove "$pkg"
    else
        echo "$pkg not found, skipping."
    fi
done

REPO_URL="https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/Packages/r"
PKGS=(
  "$REPO_URL/rocky-release-9.7-1.3.el9.noarch.rpm"
  "$REPO_URL/rocky-repos-9.7-1.3.el9.noarch.rpm"
  "$REPO_URL/rocky-gpg-keys-9.7-1.3.el9.noarch.rpm"
)
sudo dnf -y install "${PKGS[@]}"

sudo rm -rf /usr/share/redhat-logos

sudo service auditd stop
sudo dnf -y --releasever=9 --allowerasing --setopt=deltarpm=false distro-sync

sudo rpm --rebuilddb

sudo systemctl reboot

sudo dnf -y install firewalld
sudo systemctl enable --now firewalld

sudo dnf -y remove kernel*el8*

#sudo rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n'

keys=(
  "gpg-pubkey-f4a80eb5-53a7ff4b"
  "gpg-pubkey-352c64e5-52ae6884"
  "gpg-pubkey-2f86d6a1-5cf7cefb"
  "gpg-pubkey-81b961a5-64106f70"
  "gpg-pubkey-621e9f35-58adea78"
  "gpg-pubkey-fd431d51-4ae0493b"
  "gpg-pubkey-d4082792-5b32db75"
)

for key in "${keys[@]}"; do
  if rpm -q "$key" &> /dev/null; then
    echo "Removing $key"
    sudo rpm -e --allmatches "$key"
  else
    echo "$key not found, skipping."
  fi
done

sudo dnf module reset '*' -y

sudo dnf clean all