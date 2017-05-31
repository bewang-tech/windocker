FROM httpd

ARG VERSION

COPY index.html windocker.ps1 windocker-${VERSION}.zip /usr/local/apache2/htdocs/
