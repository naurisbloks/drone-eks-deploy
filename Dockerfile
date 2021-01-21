FROM alpine:3.10 as dependencies

RUN apk add python3 curl --no-cache \
  && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
  && unzip awscli-bundle.zip \
  && python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl

FROM alpine:3.10 as final

RUN apk add python3 bash --no-cache
COPY --from=dependencies --chown=root:root /usr/local/aws /usr/local/aws
COPY --from=dependencies --chown=root:root /usr/local/bin/aws /usr/local/bin/aws
COPY --from=dependencies --chown=root:root /kubectl /usr/local/bin/kubectl
COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT [ "/bin/bash" ]

CMD [ "/bin/entrypoint.sh" ]
