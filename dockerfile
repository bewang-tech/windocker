FROM httpd

RUN apt-get update \
    && apt-get install -y --no-install-recommends zip \
    && rm -r /var/lib/apt/lists/*

COPY web/index.html /usr/local/apache2/htdocs/
COPY bin/windocker.ps1 /usr/local/apache2/htdocs/
COPY . /tmp/

RUN cd /tmp \
  && zip -r /usr/local/apache2/htdocs/windocker.zip bin lib \
  && rm -rf bin lib web dockerfile
