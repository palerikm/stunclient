FROM ubuntu
MAINTAINER Pål-Erik Martinsen <palmarti@cisco.com>

# XXX: Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn


COPY . stunclient

RUN \
 buildDeps='build-essential zlib1g-dev git cmake';set -x &&\
 apt-get update && apt-get install -y ca.certificates libssl-dev libbsd-dev curl jq nodejs-legacy npm $buildDeps  --no-install-recommends &&\
 rm -rf /var/lib/apt/lists/* &&\
 npm install --global csv2json &&\
 cd stunclient &&\
 rm -rf build &&\
 ./build.sh &&\
 make -C build install &&\
 cd .. &&\
 apt-get purge -y --auto-remove $buildDeps

WORKDIR stunclient
RUN pwd
#CMD ["/bin/bash", "ls -a"]
#CMD stunclient/serverping.sh
ENTRYPOINT ["./serverping.sh"]
CMD ["-i eth0" "-f test.json" "-r 2" "-p http://ec2-35-166-234-254.us-west-2.compute.amazonaws.com/discovery-result"]
