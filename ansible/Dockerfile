FROM ubuntu:16.04

# Install ansible
RUN \
    apt-get update -y && \
    apt-get install -y software-properties-common && \
    apt-add-repository --yes --update ppa:ansible/ansible

RUN \
    apt-get update -y && \
    apt-get install -y ansible

# Copy ansible configuration file.
COPY --chown=ansible ansible.cfg /etc/ansible/

WORKDIR /work
