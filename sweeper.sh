# MM    MM              dd           bb                         lll  1  hh      333333
# MMM  MMM   aa aa      dd   eee     bb      yy   yy      aa aa lll 111 hh         3333 nn nnn
# MM MM MM  aa aaa  dddddd ee   e    bbbbbb  yy   yy     aa aaa lll  11 hhhhhh    3333  nnn  nn
# MM    MM aa  aaa dd   dd eeeee     bb   bb  yyyyyy    aa  aaa lll  11 hh   hh     333 nn   nn
# MM    MM  aaa aa  dddddd  eeeee    bbbbbb       yy     aaa aa lll 111 hh   hh 333333  nn   nn
#                                             yyyyy
# Support - al1h3n(tg,ds) | Donate me - paypal.me/al1h3n
# Cleaner.sh v1 - First launch.
# Part of the Cleanus Pack.
# ==============================================================================

#!/bin/bash
echo -e "\033]0;Sweeper v1 - al1h3n | PART of Cleanus Pack v1\007"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"

# If script is not run as root, restart it as root automatically.
if [ $EUID -ne 0 ];then
   echo -e "${YELLOW}Elevation needed. Restarting with sudo..${RESET}"
   exec sudo /bin/bash "$0" "$@"
fi

echo -e "\033[38;5;213mSweeper by\033[0m \033[38;5;171mal1h3n${RESET} | \033[38;5;141mPART${RESET} of \033[38;5;226mCleanus Pack${RESET}"
echo You have to use sudo command before launching the script.
echo -e "${GREEN}=========================================="
echo -e "    STARTING SYSTEM MAINTENANCE TASK      "
echo -e "==========================================${RESET}"

echo -e "\n\033[38;5;37m[1/2] Cleaning kernel (trash, logs, tmp, swap)...${RESET}"
echo " -> Cleaning temporary files..."
rm -rf /tmp/*
journalctl --vacuum-time=1d
for user_dir in /home/*;do
    if [ -d $user_dir ];then
        user_name=$(basename $user_dir)
        echo -e " -> Cleaning trash & cache for \033[38;5;197m$user_name${RESET}"
        rm -rf $user_dir/.local/share/Trash/*
        rm -rf $user_dir/.cache/*
    fi
done
sync;sh -c 'echo 3 > /proc/sys/vm/drop_caches' # 3 is the best.
swapoff -a #&&swapon -a
# Only works if you have enough RAM to hold current swap data.

echo -e "\n\033[38;5;33m[2/2] Cleaning package managers...${RESET}"
exists(){
	command -v $1&>/dev/null
}

if exists pacman;then # Arch, Endeavour, Cachy, Manjaro etc.
pacman -Syu --noconfirm;pacman -Runs $(pacman -Qdtq) --noconfirm;pacman -Scc --noconfirm

elif exists apt;then # Debian, Ubuntu, Mint, ELementaryOS, Kali
apt update;apt full-upgrade -y;apt autoremove -y;apt clean;apt autoclean

elif exists dnf;then # Fedora, RedHat
dnf upgrade --refresh -y
dnf clean all;dnf autoremove -y
dnf repoquery --extras --qf '%{name}'|xargs dnf remove
package-cleanup --orphans --leaves --cleandupes --noprompt

elif exists apk;then # Alpine
apk update;apk upgrade
apk cache purge;apk del

elif exists zypper;then # OpenSUSE
zypper refresh;zypper dist-upgrade -y
zypper clean --all

elif exists emerge;then # Gentoo
emerge -a --sync;emerge -avuDN @world;emerge -a -c --ask --depclean
eclean-dist -d;eclean-pkg

elif exists xbps-install;then # Void Linux
xbps-install -Syu;xbps-remove -Ooy;vkpurge rm all

elif exists eopkg;then # Solis
eopkg ur -y;eopkg upgrade -y;eopkg rmo;eopkg dc

elif exists slackpkg;then # Slackware
yes|slackpkg update;yes|slackpkg upgrade-all;slackpkg clean-system

else
echo There is no appropiate package manager for your system.
fi

if exists paccache;then
paccache -ruk0;paccache -rk1
# Delete removed packages from disk, keep 2 recent versions
# Uses pacman-contrib
fi

if exists apt-get;then # Older manager of Debian family
apt-get full-upgrade -y;apt-get autoremove -y;apt-get clean
fi

if exists flatpak;then # Additional PMs
flatpak update -y;flatpak uninstall -y --unused
fi

if exists snap;then
yes|snap refresh;rm -rf /var/lib/snapd/cache/*
fi

if exists brew;then
brew update;brew upgrade;brew upgrade --cask
brew autoremove;brew cleanup --prune=all
fi

if exists yay;then # One of the most useful
yay -Syu --noconfirm;yay -Runs $(yay -Qdtq) --noconfirm;yay -Scc --noconfirm
fi

echo -e "\n\033[38;5;46m==========================================${RESET}"
echo -e "\033[38;5;46m      SYSTEM CLEANING COMPLETE!           ${RESET}"
echo -e "\033[38;5;46m==========================================${RESET}"
