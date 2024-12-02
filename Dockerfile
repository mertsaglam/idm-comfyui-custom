FROM python:3.10.12-slim

ENV DEBIAN_FRONTEND=noninteractive \
    NVIDIA_DRIVER_CAPABILITIES=all \
    PIP_PREFER_BINARY=1 \
    PYTHONUNBUFFERED=1

# Setup system packages
COPY builder/setup.sh /setup.sh
RUN /bin/bash /setup.sh && \
    rm /setup.sh

COPY builder/requirements.txt /requirements.txt 
RUN pip install -r /requirements.txt && \
    rm /requirements.txt

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /ComfyUI

RUN pip install -r requirements.txt && pip cache purge

# Clone custom Nodes
RUN git -C ./custom_nodes clone --depth 1 https://github.com/storyicon/comfyui_segment_anything
RUN git -C ./custom_nodes clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux
RUN git -C ./custom_nodes clone --depth 1 https://github.com/mertsaglam/ComfyUI-IDM-VTON


# Sam
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M 'https://huggingface.co/lkeab/hq-sam/resolve/main/sam_hq_vit_h.pth' -d './models/sams' -o 'sam_hq_vit_h.pth'

# Grounding Dino
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M 'https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/GroundingDINO_SwinB.cfg.py' -d './models/grounding-dino' -o 'GroundingDINO_SwinB.cfg.py'
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M 'https://huggingface.co/ShilongLiu/GroundingDINO/resolve/main/groundingdino_swinb_cogcoor.pth' -d './models/grounding-dino' -o 'groundingdino_swinb_cogcoor.pth'

# Densepose
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M 'https://huggingface.co/LayerNorm/DensePose-TorchScript-with-hint-image/resolve/main/densepose_r50_fpn_dl.torchscript' -d './custom_nodes/comfyui_controlnet_aux/ckpts/LayerNorm/DensePose-TorchScript-with-hint-image' -o 'densepose_r50_fpn_dl.torchscript'

# IDM-VTON models
RUN cd ./custom_nodes/ComfyUI-IDM-VTON && python install.py

# Custom nodes requirements
COPY --chmod=755 src/* ./
RUN ./install_custom_node_dependencies.sh
RUN pip install huggingface_hub==0.25.2 matplotlib


CMD /ComfyUI/start.sh