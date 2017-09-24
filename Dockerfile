FROM centos:latest
MAINTAINER Naftuli Kay <me@naftuli.wtf>

# install runit; script removes itself on success
COPY scripts/install-runit.sh /tmp/install-runit
RUN bash /tmp/install-runit
