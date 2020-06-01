#!/bin/bash

#test -e /etc/courier/esmtpd || cp -a /etc/courier.docker/* /etc/courier

OVERRIDE_CONF='/conf'
CONF='/etc/courier'

for d in `find "${OVERRIDE_CONF}" -mindepth 1 -type d`; do
	basedir=`echo "${d}" |sed "s;^${OVERRIDE_CONF}/;;"`
	confdir="${CONF}/${basedir}"

	if [[ ! -e "${confdir}" ]]; then
		mkdir "${confdir}"
	elif [[ ! -d "${confdir}" ]]; then
		echo "${confdir} is not a directory. Thus cannot override with a directory."
		exit 1
	fi
done

for f in `find "${OVERRIDE_CONF}" -mindepth 1 -type f ! -name '*.docker'`; do
	basefile=`echo "${f}" |sed "s;^${OVERRIDE_CONF}/;;"`
	conffile="${CONF}/${basefile}"

	if [[ ! -e "${conffile}" ]]; then
		cp -a "${f}" "${conffile}"
	elif [[ -f "${conffile}" ]]; then
		mv "${conffile}" "${f}.docker"
		cp -a "${f}" "${conffile}"
	else
		echo "${conffile} is not a file. Thus cannot override with a file."
	fi
done


/usr/sbin/makeacceptmailfor
/usr/sbin/makealiases
/usr/sbin/makeuserdb
/usr/sbin/makehosteddomains
/usr/sbin/makealiases
/usr/sbin/makesmtpaccess

#/usr/lib/courier/courier-authlib/authdaemond &
#/usr/sbin/couriertcpd -address=0 -maxprocs=40 -maxperip=20 -nodnslookup -noidentlookup 143 /usr/lib/courier/courier/imaplogin /usr/bin/imapd Maildir

/usr/sbin/authdaemond start

sleep 1
for home in `/usr/sbin/authenumerate |awk '{print $4}'`; do
	if [[ ! -e "$home" ]]; then
		mkdir -p "$home"
		/usr/bin/maildirmake "$home/maildir"
	fi
done

chown -R 8:12 /mail
chown -R 8:12 /etc/courier
chmod go-wrx /etc/courier/maildroprc

/usr/sbin/esmtpd start
/usr/sbin/courier-imapd start
/usr/sbin/courier-imapd-ssl start
/usr/sbin/courier start

#umask 0111
while true; do
	#nc -lU /dev/log |sed 's/</\n</g' >&2
	sleep 10
done
