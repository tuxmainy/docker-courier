FROM gentoo/portage:latest as portage
FROM gentoo/stage3:amd64

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# courier and pythonfilter install + activate + cleanup
RUN echo '=mail-filter/courier-pythonfilter-3.0.2-r1' > /etc/portage/package.accept_keywords && \
	emerge mail-mta/courier mail-filter/courier-pythonfilter dev-python/pyspf dev-python/pydns && \
	ln -s /usr/bin/pythonfilter /usr/libexec/filters && \
	filterctl start pythonfilter && \
	rm -rf /var/db/repos/gentoo

# courier config
RUN sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/esmtpd && \
	sed -i 's;^TCPDOPTS=.\+$;TCPDOPTS="-stderrlogger=/usr/sbin/courierlogger -nodnslookup -noidentlookup";' /etc/courier/imapd && \
	sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="| /usr/bin/maildrop";' /etc/courier/courierd && \
	sed -i 's;^MAILDROPDEFAULT=.\+$;MAILDROPDEFAULT="./maildir";' /etc/courier/courierd && \
	sed -i 's;^authmodulelist=.\+$;authmodulelist="authuserdb";' /etc/courier/authlib/authdaemonrc
#RUN sed -i 's;^DEFAULTDELIVERY=.\+$;DEFAULTDELIVERY="./maildir";' /etc/courier/courierd

# courier runtime
ADD start.sh /
RUN chmod +x /start.sh

ADD userdb.example /etc/courier/authlib

EXPOSE 25
EXPOSE 143
EXPOSE 993

VOLUME /conf
VOLUME /mail

CMD /start.sh
