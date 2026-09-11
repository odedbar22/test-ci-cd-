FROM python:3.14-slim

WORKDIR /app

COPY app/server.py app/server.py
COPY scripts/start.sh scripts/start.sh
COPY VERSION VERSION

RUN chmod 0755 /app /app/app /app/scripts /app/scripts/start.sh \
    && chmod 0644 /app/app/server.py /app/VERSION

USER 10001:10001

EXPOSE 8080

CMD ["./scripts/start.sh"]
