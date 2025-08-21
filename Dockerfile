FROM cribl/cribl:latest

# Create a cert
# RUN cd /etc/ssl/certs/ && openssl req -newkey rsa:4096  -x509  -sha512  -days 365 -nodes -out certificate.pem -keyout privatekey.pem -passout pass:MyS3cUr3PaSsPhRaS3 \
# -subj "/C=US/ST=California/L=San Francisco/O=Evil Coffee Co/OU=Data Team/CN=localhost" \
# -addext "subjectAltName = DNS:localhost,DNS:127.0.0.1,DNS:*.localhost,IP:127.0.0.1,IP:::1" && \
# openssl x509 -in /etc/ssl/certs/certificate.pem -out ~/criblcertificate.crt

# Add cert
COPY ./certs/certificate.pem ./certs/privatekey.pem ./certs/criblcertificate.crt /etc/ssl/certs/
COPY ./certs/criblcertificate.crt /root/

# Create the 'cribl' group (if it doesn't exist)
RUN groupadd --gid 999 cribl || true

# Create the 'cribl' user with the specified UID and GID, and home directory
RUN useradd --uid 999 --gid 999 --create-home --home-dir /home/cribl --shell /bin/bash cribl

# Add the password setup commands directly into the Dockerfile
RUN echo "cribl:CriblAdmin123" | chpasswd
RUN echo "root:Sup3rS3cure#2" | chpasswd

# Set ownership of /opt/cribl and /home/cribl to the cribl user
RUN chown -R cribl:cribl /opt/cribl /home/cribl

# Set the entrypoint to the Cribl executable
USER cribl:cribl
ENTRYPOINT ["/opt/cribl/bin/cribl", "server"]

# Add sample files
COPY ./sample_logs/crowdstrike_fdr.json ./sample_logs/fortinet.json ./sample_logs/okta.json ./sample_logs/zscalar_nss.json /opt/cribl/data/samples/
COPY ./sample_logs/proto.csv /opt/cribl/data/lookups/
COPY ./sample_logs/sample.yml /opt/cribl/local/

# RUN apt-get update && apt-get install -y procps