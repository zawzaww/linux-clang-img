# Docker Container Base Image.
FROM zawzaww/debian-linux:stable

# Setup environment variables.
ENV KERNEL_USER=zawzaw \
    KERNEL_COMPILER=clang \
    KERNEL_BUILDTOOL=make \
    KERNEL_WORKDIR=/linux

# Setup Linux workdir.
WORKDIR ${KERNEL_WORKDIR}

# Add a new user for Linux workdir.
RUN useradd --create-home ${KERNEL_USER}

# Change owner for Linux workdir.
RUN chown -R ${KERNEL_USER}:${KERNEL_USER} ${KERNEL_WORKDIR}
USER ${KERNEL_USER}

# Check Clang/LLVM compiler and Make version.
RUN ${KERNEL_COMPILER} --version && \
    ${KERNEL_BUILDTOOL} --version

# Compile and Boot Linux kernel in QEMU.
CMD make clean && make mrproper && \
    make CC=${KERNEL_COMPILER} x86_64_defconfig && \
    make CC=${KERNEL_COMPILER} -j$(nproc --all) && \
    qemu-system-x86_64 \
    -kernel arch/x86_64/boot/bzImage \
    -append "console=ttyS0" \
    -nographic \
    -serial mon:stdio
