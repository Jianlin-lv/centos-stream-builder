#!/bin/bash
set -x

rm -rf /mnt/centos-stream-builder

cd /mnt/ && sudo git clone https://github.com/Jianlin-lv/centos-stream-builder.git

docker stop centos_build || true; sudo docker rm centos_build || true
docker run -d --network=host --privileged --name centos_build -v /mnt:/mnt quay.io/centos/centos:stream10 \
	/bin/bash -c "while true;do echo hello docker;sleep 1;done"

docker exec centos_build /bin/bash -c ' cd /mnt/centos-stream-builder && \
    chmod 755 ./scripts/setup_build_env.sh && \
    ./scripts/setup_build_env.sh'

docker exec centos_build /bin/bash -c ' cd /mnt/centos-stream-builder && \
    chmod 755 ./scripts/kernel_build.sh && \
    ./scripts/kernel_build.sh'

docker exec centos_build /bin/bash -c ' cd /mnt/centos-stream-builder && \
    chmod 755 ./scripts/rebuild_installation_image.sh && \
    ./scripts/rebuild_installation_image.sh'

