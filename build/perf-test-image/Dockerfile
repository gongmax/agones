FROM gcr.io/cloud-builders/gcloud

RUN apt-get update && \
    apt-get install -y wget make && \
    apt-get clean

# install kubectl without gcloud as we want the last version
ENV KUBECTL_VER 1.26.6
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl && \
    chmod go+rx ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

COPY *.sh /root/
RUN chmod +x /root/*.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]
