# patch argocd repo server to be able to decrypt secrets
#force release 
FROM quay.io/argoproj/argocd:v2.1.1

# Switch to root for the ability to perform install
USER root
ARG GOPASS_VERSION="1.12.8"
# Install tools needed for your repo-server to retrieve & decrypt secrets, render manifests 
# (e.g. curl, awscli, gpg, sops)
RUN apt-get update && \
    apt-get install -y \
        wget \
        jq \
        gpg &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    wget https://github.com/gopasspw/gopass/releases/download/v$GOPASS_VERSION/gopass-$GOPASS_VERSION-linux-amd64.tar.gz &&\
    tar xf ./gopass-$GOPASS_VERSION-linux-amd64.tar.gz &&\
    mv ./gopass /usr/local/bin &&\
    rm -rf ./gopass-$GOPASS_VERSION-linux-amd64* &&\
    chmod +x /usr/local/bin/gopass

COPY ./scripts/* /home/argocd/

RUN apt-get install git git-man libcurl3-gnutls libidn2-0

# Switch back to non-root user
USER argocd
