FROM gentoo/portage:latest as portage

FROM gentoo/stage3-amd64:latest

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN emerge mail-mta/courier && \
	rm -rf /var/db/repos/gentoo

RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/esmtpd
RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/imapd
#RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="| /usr/bin/maildrop";' /etc/courier/courierd
RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="./maildir";' /etc/courier/courierd
RUN sed -i 's;^MAILDROPDEFAULT=.\+$;MAILDROPDEFAULT="./maildir";' /etc/courier/courierd

RUN sed -i 's;^authmodulelist=.\+$;authmodulelist="authuserdb";' /etc/courier/authlib/authdaemonrc

ADD start.sh /
RUN chmod +x /start.sh

ADD userdb.example /etc/courier/authlib

RUN mkdir -p /run/courier/authdaemon

RUN mv /etc/courier /etc/courier.docker

EXPOSE 25
EXPOSE 143
EXPOSE 993

VOLUME /etc/courier
VOLUME /mail

CMD /start.sh
