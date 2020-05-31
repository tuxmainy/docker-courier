FROM gentoo/portage:latest as portage

FROM gentoo/stage3-amd64:latest

# gentoo base
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# courier install
RUN emerge mail-mta/courier

# courier config
RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/esmtpd
RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/imapd
#RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="| /usr/bin/maildrop";' /etc/courier/courierd
RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="./maildir";' /etc/courier/courierd
RUN sed -i 's;^MAILDROPDEFAULT=.\+$;MAILDROPDEFAULT="./maildir";' /etc/courier/courierd
RUN sed -i 's;^authmodulelist=.\+$;authmodulelist="authuserdb";' /etc/courier/authlib/authdaemonrc

# courier runtime
ADD start.sh /
RUN chmod +x /start.sh
RUN mkdir -p /run/courier/authdaemon

ADD userdb.example /etc/courier/authlib

# pythonfilter
RUN echo '=mail-filter/courier-pythonfilter-3.0.2' > /etc/portage/package.accept_keywords && \
	emerge mail-filter/courier-pythonfilter dev-python/pyspf dev-python/pydns && \
	ln -s /usr/bin/pythonfilter /usr/libexec/filters && \
	filterctl start pythonfilter

# docker config
RUN mv /etc/courier /etc/courier.docker

# clean
RUN rm -rf /var/db/repos/gentoo

EXPOSE 25
EXPOSE 143
EXPOSE 993

VOLUME /etc/courier
VOLUME /mail

CMD /start.sh
