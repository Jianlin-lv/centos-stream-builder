# centos-stream-builder
centos stream scripts and kernel patches for os installer pxe image

### Build Execution
Main build command:
```bash
cd centos-stream-builder && ./build_in_container.sh > build_log 2>&1
```

The build_in_container.sh script performs the following operations:
1. Clones the repository to /mnt/centos-stream-builder-jianlin
2. Starts a privileged Docker container using quay.io/centos/centos:stream10
3. Executes the three main build scripts sequentially inside the container

