ARG FROM_BASE=perl-5.24.3:20180210
FROM $FROM_BASE

# version of this docker image
ARG CONTAINER_VERSION=1.0.0 
LABEL version=$CONTAINER_VERSION  

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh 'Perl-CARTON'
RUN rm -rf /tmp/*

# commands which are run when building containers based on this image
ONBUILD COPY cpanfile* /usr/src/app/
ONBUILD RUN /carton.build ; rm /carton.build
ONBUILD ENV PERL5LIB=/usr/src/app/local/lib/perl5:$PERL5LIB
ONBUILD ENV APPDIR=/usr/src/myapp
ONBUILD WORKDIR ${APPDIR}