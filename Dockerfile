# build runtime image
FROM registry.redhat.io/ubi8/ubi-minimal:8.9

USER 0

RUN microdnf install -y krb5-workstation krb5-libs

COPY krb5.conf /opt/app-root/krb5.conf

# Copy scripts for connecting to Domain
COPY login.sh /opt/app-root/

RUN mkdir /opt/app-root/krb5

RUN chmod +x /opt/app-root/login.sh

# Fix permissions
RUN chown -R 1001:0 /opt/app-root 

RUN chgrp -R 0 /opt/app-root
RUN chmod -R og+rw /opt/app-root

USER 1001

CMD ["sh","-c","mv /opt/app-root/krb5.conf /etc/krb5.conf.d/krb5.conf && /opt/app-root/login.sh"]
