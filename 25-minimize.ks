# Minimize the image by dropping some unnecessary data like i18n or man pages
# vim: set ft=bash:sw=2:ts=2:et
#
# Some ideas from:
#
# https://github.com/weldr/lorax/blob/rhel9-branch/share/templates.d/99-generic/runtime-cleanup.tmpl
#
%post

# New Part
# Ensure we don't have the same random seed on every image, which
# could be bad for security at a later point...
echo " * purge existing random seed to avoid identical seeds everywhere"
rm -f /var/lib/random-seed

echo " * disable sshd and purge existing SSH host keys"
rm -f /etc/ssh/ssh_host_*key{,.pub}
systemctl disable sshd.service

## other removals
rm -rf /home /media /opt /srv /tmp/*
rm -rf /usr/etc /usr/games /usr/local /usr/tmp
rm -rf /usr/share/doc /usr/share/info /usr/share/man /usr/share/gnome
rm -rf /usr/share/mime/application /usr/share/mime/audio /usr/share/mime/image
rm -rf /usr/share/mime/inode /usr/share/mime/message /usr/share/mime/model
rm -rf /usr/share/mime/multipart /usr/share/mime/packages /usr/share/mime/text
rm -rf /usr/share/mime/video /usr/share/mime/x-content /usr/share/mime/x-epoc
rm -rf /var/db /var/games /var/tmp /var/yp /var/nis /var/opt /var/local
rm -rf /var/mail /var/spool /var/preserve /var/report
rm -rf /var/lib/rpm/* /var/lib/yum /var/lib/dnf

## remove all manuals
rm -rf /usr/share/doc
rm -rf /usr/share/man

## clean up the files created by various '> /dev/null's
rm -f /dev/*

## icons cache
rm -rf /usr/share/icons/*/icon-theme.cache

## logrotate isn't useful in anaconda
rm -f /etc/logrotate.d

rm -rf lib/modules/*/{build,source,*.map}

rpm -ql fedora-release | rm -rf $(grep -v "/etc/os-release" | grep -v "/usr/lib/os-release" | grep -v "/usr/lib/os.release.d/*")

## keep enough of shadow-utils to create accounts
rpm -ql shadow-utils | rm -rf $(grep -v "/usr/bin/chage" | grep -v "/usr/sbin/chpasswd" | grep -v "/usr/sbin/groupadd" | grep -v "/usr/sbin/useradd" | grep -v "/etc/default/useradd")

## no services to turn on/off (keep the /etc/init.d link though)
rpm -ql chkconfig | rm -rf $(grep -v "/etc/init.d")

## anaconda needs this to do media check
rpm -ql isomd5sum | rm -rf $(grep -v "/usr/bin/checkisomd5")

## systemd-nspawn isn't very useful and doesn't link anyway without iptables,
## and there's no need for a bunch of zsh files without zsh
rpm -ql systemd | rm -rf $(grep "/usr/bin/systemd-nspawn")
rpm -ql systemd | rm -rf $(grep "/usr/share/zsh")

## remove unused themes, theme engines, icons, etc.
rpm -ql gtk2 | rm -rf $(grep "engines")
rpm -ql gtk2 | rm -rf $(grep "printbackends")
rpm -ql gtk2 | rm -rf $(grep "/usr/share/themes/*")
rpm -ql gtk3 | rm -rf $(grep "printbackends")
rpm -ql gtk3 | rm -rf $(grep "/usr/share/themes/*")

## filesystem tools
rpm -ql e2fsprogs | rm -rf $(grep "/usr/share/locale/*")
rpm -ql xfsprogs | rm -rf $(grep "/usr/share/locale/*")
rpm -ql xfsdump | rm -rf $(grep -v "/usr/sbin/*")

## other package specific removals
rpm -ql GConf2 | rm -rf $(grep "/etc/rpm/*")
rpm -ql GConf2 | rm -rf $(grep "/etc/xdg/*")
rpm -ql GConf2 | rm -rf $(grep "/usr/bin/*")

##rpm -ql | rm -rf $(grep "")

# OLD PART
echo " * remove unused drivers (sound, media, nls, fs, wifi)"
rm -rf /lib/modules/*/kernel/sound \
  /lib/modules/*/kernel/drivers/{media,hwmon,rtc,input/joystick,bluetooth,edac} \
  /lib/modules/*/kernel/net/{atm,bluetooth,sched,sctp,rds,l2tp,decnet} \
  /lib/modules/*/kernel/fs/{nls,ocfs2,ceph,nfsd,ubifs,nilfs2}

echo " * remove unused firmware (sound, wifi)"
rm -rf /usr/lib/firmware/*wifi* \
  /usr/lib/firmware/v4l* \
  /usr/lib/firmware/dvb* \
  /usr/lib/firmware/{yamaha,korg,liquidio,emu,dsp56k,emi26} \
  /usr/lib/firmware/{ath9k,ath10k}

echo " * dropping big and compressing small cracklib dict"
mv -f /usr/share/cracklib/cracklib_small.hwm /usr/share/cracklib/pw_dict.hwm
mv -f /usr/share/cracklib/cracklib_small.pwd /usr/share/cracklib/pw_dict.pwd
mv -f /usr/share/cracklib/cracklib_small.pwi /usr/share/cracklib/pw_dict.pwi
gzip -9 /usr/share/cracklib/pw_dict.pwd

# 100MB of locale archive is kind unnecessary; we only do en_US.utf8
# this will clear out everything we don't need; 100MB => 2.1MB.
echo " * minimizing locale-archive binary / memory size"
localedef --list-archive | grep -Eiv '(en_US|fdi)' | xargs localedef -v --delete-from-archive
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
/usr/sbin/build-locale-archive

echo " * purging all other locale data"
ls -d /usr/share/locale/* | grep -v fdi | xargs rm -rf

echo " * purging images"
rm -rf /usr/share/backgrounds/* /usr/share/kde4/* /usr/share/anaconda/pixmaps/rnotes/*

echo " * purging rubygems cache"
rm -rf /usr/share/gems/cache/*

echo " * truncating various logfiles"
for log in yum.log dracut.log lastlog yum.log; do
    truncate -c -s 0 /var/log/${log}
done

echo " * removing trusted CA certificates"
truncate -s0 /usr/share/pki/ca-trust-source/ca-bundle.trust.crt
update-ca-trust

echo " * setting up hostname"
echo fdi > /etc/hostname

echo " * locking root account"
passwd -l root

echo " * store list of packages sorted by size"
rpm -qa --queryformat '%{SIZE} %{NAME} %{VERSION}%{RELEASE}\n' | sort -n -r > /usr/PACKAGES-LIST

echo " * cleaning up yum cache and removing rpm database"
yum clean all
rm -rf /var/lib/{yum,rpm}/*

# no more python loading after this step
echo " * removing python precompiled *.pyc files"
find /usr/lib64/python*/ /usr/lib/python*/ -name *py[co] -print0 | xargs -0 rm -f
%end

%post --nochroot
echo " * disquieting the boot process"
sed -i -e's/ rhgb//g' -e's/ quiet//g' $LIVE_ROOT/isolinux/isolinux.cfg
%end
