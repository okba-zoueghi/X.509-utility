FROM ubuntu

RUN apt-get update && apt-get install git -y

RUN mkdir -p /home

WORKDIR /home

RUN git clone https://github.com/okba-zoueghi/X.509-utility

WORKDIR /home/X.509-utility
