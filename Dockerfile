FROM panubo/sshd:1.5.0
WORKDIR /app
COPY src/sshd_config /etc/ssh/sshd_config
RUN apk add curl iproute2 
COPY src/entrypoint.sh /app
COPY src/dockerized_airgapt.sh /app
CMD [""]
ENTRYPOINT ["/app/entrypoint.sh"]
