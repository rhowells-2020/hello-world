FROM alpine:latest
LABEL maintainer "r.howells@imperial.ac.uk"
LABEL source "https://github.com/rhowells-2020/hello-world"

# Set working directory
WORKDIR /app
ENV HOME /app

# Update and install packages
RUN apk add -U python3

# Create a non-root user and set file permissions
RUN addgroup -S app \
    && adduser -S -g app -u 1000 app \
    && chown -R app:app /app

# Run as the non-root user
USER 1000

COPY index.html /app

ENTRYPOINT ["/usr/bin/python3", "-m", "http.server", "8080"]
