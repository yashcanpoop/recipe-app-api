FROM python:3.9-alpine

LABEL maintainer="yashcancode"

# Set environment variable to unbuffer Python output
ENV PYTHONUNBUFFERED=1

# Copy requirements file
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the app code to the /app directory
COPY ./app /app

# Set working directory
WORKDIR /app

# Expose port 8000
EXPOSE 8000

# Create a virtual environment, install dependencies, and create a new user
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser\ 
        --disabled-password \
        --no-create-home \
        django-user

# Add virtual environment to the PATH
ENV PATH="/py/bin:$PATH"

# Switch to non-root user
USER django-user
