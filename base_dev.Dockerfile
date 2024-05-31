FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# install python
RUN apt-get update && apt-get install -y python3.10 python3.10-dev python3-pip \
        && ln -nfs /usr/bin/python3.10 /usr/bin/python \
        && python -m pip install --upgrade pip

RUN apt-get update && apt install -y ffmpeg

# install basic tools
RUN apt-get update && apt-get install -y vim net-tools less curl telnet lsof

# install torch and cuda
RUN pip3 install torch==2.3.0 torchvision torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu118

# app relative
WORKDIR /workspace

RUN cd /usr/local/cuda-11.8/targets/x86_64-linux/lib/ && ln -s libnvrtc.so.11.2 libnvrtc.so

ENV CLI_ARGS=""
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib/python3.10/dist-packages/nvidia/cudnn/lib:/usr/local/cuda-11.8/targets/x86_64-linux/lib/"
