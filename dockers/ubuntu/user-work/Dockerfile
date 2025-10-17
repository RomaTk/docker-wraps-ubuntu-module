ARG BASED_ON="ubuntu:latest"
FROM $BASED_ON

WORKDIR /working-env/ubuntu/user-work

COPY ./create.sh ./create.sh
COPY ./remove.sh ./remove.sh
COPY ./is-user-exists.sh ./is-user-exists.sh
COPY ./flock-file.lock ./flock-file.lock