# Use the official Amazon Linux 2 as the base image
FROM amazonlinux:2 AS builder

# Update the system and install required packages
RUN yum update -y && \
    yum install -y git

# Clone the repository from your GitHub
RUN git clone https://github.com/benjamindavisdc/may23pipeline01.git /tmp/temp2

# Stage 2: Build the final image
FROM amazonlinux:2

# Update the system and install required packages
RUN yum update -y && \
    yum install -y httpd python3 python3-pip python3-devel gcc httpd-devel  \   
    && yum clean all \
    && rm -rf /var/cache/yum

# Install mod_wsgi package
RUN amazon-linux-extras install -y python3.8 && \
    pip3 install mod_wsgi \
    && yum clean all

# Install Flask and other required Python packages
RUN python3 -m venv /opt/flask-app/flask-venv && \
    /opt/flask-app/flask-venv/bin/pip3 install flask

# Copy the files from the builder stage to the appropriate locations
COPY --from=builder /tmp/temp2/app.py /opt/flask-app/app.py
COPY --from=builder /tmp/temp2/apache-flask.wsgi /var/www/apache-flask/apache-flask.wsgi
COPY --from=builder /tmp/temp2/apache-flask.conf /etc/httpd/conf.d/apache-flask.conf
COPY --from=builder /tmp/temp2/templates /var/www/apache-flask/templates
COPY --from=builder /tmp/temp2/static /var/www/apache-flask/static
COPY --from=builder /tmp/temp2/ /var/www/apache-flask/

# LINK apache config to docker logs.
RUN ln -sf /dev/stdout /var/log/httpd/access_log && \
    ln -sf /dev/stderr /var/log/httpd/error_logs

# Expose port 80 for incoming HTTP traffic
EXPOSE 80

WORKDIR /var/www/apache-flask

# Start the Apache web server when the container launches
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]