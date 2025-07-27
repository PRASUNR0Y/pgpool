FROM bitnami/pgpool:latest

LABEL maintainer="Pgpool Team"
LABEL description="Enhanced Pgpool-II with environment variable configuration support"
LABEL version="1.0.0"

USER root

# Copy custom configuration scripts
COPY scripts/custom-entrypoint.sh /opt/bitnami/scripts/pgpool/custom-entrypoint.sh
COPY config/pgpool.conf.template /opt/bitnami/pgpool/conf/pgpool.conf.template

RUN chmod +x /opt/bitnami/scripts/pgpool/custom-entrypoint.sh

USER 1001

ENTRYPOINT ["/opt/bitnami/scripts/pgpool/custom-entrypoint.sh"]
CMD ["/opt/bitnami/scripts/pgpool/run.sh"] 