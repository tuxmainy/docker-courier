test -e /etc/courier/esmtpd || cp -a /etc/courier.docker/* /etc/courier

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
	if [ ! -d "$home" ]; then
		mkdir -p "$home"
		/usr/bin/maildirmake "$home/maildir"
		chown -R 101 "$home"
	fi
done

/usr/sbin/esmtpd start
/usr/sbin/imapd start
/usr/sbin/imapd-ssl start
/usr/sbin/courier start

while true; do
	sleep 10
done
