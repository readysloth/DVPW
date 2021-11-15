FROM ubuntu

COPY src /
COPY disk.img /

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y python3 python3-pip qemu-system-x86
RUN pip3 install -r requirements.txt


CMD python3 main.py disk.img
