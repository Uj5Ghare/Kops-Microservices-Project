# Build stage
FROM python:3.9-alpine AS builder

WORKDIR /app

RUN apk add --no-cache \
    build-base=0.5-r3 \
    linux-headers=6.14.2-r0

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Final stage
FROM python:3.9-alpine

WORKDIR /app

ENV INSTANA_SERVICE_NAME=payment

COPY --from=builder /install /usr/local
COPY *.py /app/
COPY payment.ini /app/

EXPOSE 8080

CMD ["uwsgi", "--ini", "payment.ini"]