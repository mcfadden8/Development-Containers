FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ARG UID=1000
ARG GID=1000

RUN groupadd -g ${GID} developer && \
    useradd -m -s /bin/zsh -u ${UID} -g ${GID} developer

USER developer
WORKDIR /home/developer

CMD ["/bin/zsh"]
