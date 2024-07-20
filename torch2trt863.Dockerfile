FROM nvcr.io/nvidia/tensorrt:24.04-py3

# install basic tools
RUN apt-get update && apt-get install -y vim net-tools less curl telnet lsof

RUN apt-get update && apt install -y ffmpeg

# install torch and cudart
RUN pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu121
RUN pip install cuda-python

RUN pip install onnxruntime-gpu==1.18.0
RUN pip install onnx==1.16.1
RUN pip install scipy scikit-learn

# app relative
WORKDIR /workspace
