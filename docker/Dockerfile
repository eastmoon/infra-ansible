FROM debian:buster-slim

# Install ssh
RUN \
    apt-get update -y && \
    apt-get install -y ssh

RUN \
    useradd -s /bin/bash -m ansible

ADD docker-entrypoint.sh /
CMD ["bin/bash", "docker-entrypoint.sh"]
