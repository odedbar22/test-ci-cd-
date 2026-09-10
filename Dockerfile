FROM python:3.14-slim

WORKDIR /app

COPY app/server.py app/server.py
COPY scripts/start.sh scripts/start.sh
COPY VERSION VERSION

RUN chmod +x scripts/start.sh

USER 10001:10001

EXPOSE 8080

CMD ["./scripts/start.sh"]
