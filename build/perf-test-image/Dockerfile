FROM gcr.io/cloud-builders/gcloud

RUN apt-get update && \
    apt-get install -y wget make && \
    apt-get clean

# install kubectl without gcloud as we want the last version
ENV KUBECTL_VER 1.26.6
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VER}/bin/linux/amd64/kubectl && \
    chmod go+rx ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# install Helm package manager
ENV HELM_VER 3.5.0
ENV HELM_URL https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz
RUN curl -L  ${HELM_URL} > /tmp/helm.tar.gz \
    && tar -zxvf /tmp/helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod go+rx /usr/local/bin/helm \
    && rm /tmp/helm.tar.gz && rm -rf /tmp/linux-amd64

COPY *.sh /root/
RUN chmod +x /root/*.sh

ENTRYPOINT [ "/root/entrypoint.sh" ]
