FROM debian

ENV DEBIAN_FRONTEND noninterative

RUN apt-get update && \
	apt-get install -y courier-imap courier-mta courier-authlib-userdb netcat-openbsd maildrop gamin && \
	rm -rf /var/lib/apt/lists/*

RUN ln -s /bin/mkdir /usr/bin/mkdir && \
	ln -s /bin/cat /usr/bin/cat

RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/esmtpd
RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/imapd
RUN sed -i 's;^authmodulelist=.\+$;authmodulelist="authuserdb";' /etc/courier/authdaemonrc
#RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="| /usr/bin/maildrop";' /etc/courier/courierd
RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="./maildir";' /etc/courier/courierd
RUN sed -i 's;^MAILDROPDEFAULT=.\+$;MAILDROPDEFAULT="./maildir";' /etc/courier/courierd

ADD start.sh /
RUN chmod +x /start.sh

ADD userdb.example /etc/courier

RUN mkdir -p /run/courier/authdaemon

RUN mv /etc/courier /etc/courier.docker

EXPOSE 25
EXPOSE 143
EXPOSE 993

VOLUME /etc/courier
VOLUME /mail

CMD /start.sh
