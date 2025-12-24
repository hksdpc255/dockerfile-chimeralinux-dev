FROM chimeralinux/chimera AS stage1

RUN apk add --upgrade --no-interactive \
        bash-completion opendoas base-cbuild-bootstrap base-kernel-devel base-devel flatpak-builder go cargo \
        rust ruby typescript yarn java-jdk-openjdk21-default python-meta python-hatch_vcs vala opencv ffmpeg \
        curl wget2 git \
        winetricks lldb gdb binutils ccache valgrind strace tcpdump clang-tools-extra tmux htop zip cloud-utils \
        util-linux subversion mercurial base-full '!base-full-sound' '!base-full-session' '!base-full-man' \
        '!base-full-locale' '!base-full-kernel' '!base-full-fonts' '!base-full-firmware' chimera-repo-user \
        && \
    apk add --no-interactive uv cppcheck hare sysstat maven python-matplotlib \
        $(apk list -q *-static | sed -e /-cross-/d -e /-mallocng-/d) && \
    apk add --no-interactive libgcc-chimera libatomic-chimera && \
    rm -rf /var/cache/apk/* && \
    ln -srv /bin/doas /bin/sudo && \
    printf '%s\n' '' '# Give users in the wheelnopw group access.' 'permit nopass :wheelnopw' >> /etc/doas.conf && \
    groupadd -r wheelnopw && \
    useradd -m -G wheelnopw dev


FROM stage1 as builder
ENV BUILD_CFLAGS="-fPIC -g0 -O3 -march=westmere -mtune=sapphirerapids -pipe -fno-fat-lto-objects -flto=full"
ENV BUILD_LDFLAGS="-g0 -O3 -flto=full -fPIC -fno-fat-lto-objects"
RUN mkdir -p /install/usr/lib && \
    apk add --no-interactive gcc && \
    GCC_VER="$(gcc --version | head -n 1 | grep -o '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | tail -n 1)" && \
    curl -L "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VER}/gcc-${GCC_VER}.tar.xz" | xzcat | tar -x && \
    ( \
        GCC_SOURCE="$(pwd)/gcc-${GCC_VER}" && \
        BUILD_DIR="$(pwd)/libstdcxx-build" && \
        mkdir -p "${BUILD_DIR}/include" && \
        ln -sf "${GCC_SOURCE}/libgcc/unwind-generic.h" "${BUILD_DIR}/include/unwind.h" && \
        cd "${BUILD_DIR}" && \
        CXXFLAGS="-fPIC -g0 -O3 -pipe -nostdinc++ -I${GCC_SOURCE}/libstdc++-v3/include -I${BUILD_DIR}/include -I${GCC_SOURCE}/libgcc" \
            CFLAGS="-fPIC -g0 -O3 -pipe" CC=gcc CXX=g++  "${GCC_SOURCE}/libstdc++-v3/configure" \
                --prefix=/usr --disable-werror --enable-shared --disable-static && \
        make -j$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4) && \
        make install DESTDIR="$(pwd)/install" && \
        cp -a install/usr/lib/*.* /install/usr/lib && \
        rm -f /install/usr/lib/libstdc++.so \
    ) && \
    rm -rf gcc-* libstdcxx-build && \
    curl -L "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(clang --version | grep -i -F 'clang version' | cut -d " " -f 3)/openmp-$(clang --version | grep -i -F 'clang version' | cut -d " " -f 3).src.tar.xz" | xzcat | tar -x && \
    ( \
        cd openmp-* && \
        sed -i .bak 's/include(LLVMCheckCompilerLinkerFlag)/function(llvm_check_compiler_linker_flag)\nendfunction()/' runtime/cmake/config-ix.cmake && \
        sed -i .bak '/include(ExtendPath)/d' runtime/src/CMakeLists.txt && \
        cmake . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
            -DCMAKE_C_FLAGS="$BUILD_CFLAGS" -DCMAKE_CXX_FLAGS="$BUILD_CFLAGS" -DLIBOMP_CPPFLAGS="$BUILD_CFLAGS" \
            -DLIBOMP_CXXFLAGS="$BUILD_CFLAGS" -DLIBOMP_LDFLAGS="$BUILD_LDFLAGS" \
            -DCMAKE_SHARED_LINKER_FLAGS="$BUILD_LDFLAGS" -DCMAKE_EXE_LINKER_FLAGS="$BUILD_LDFLAGS -fPIE" \
            -DLIBOMP_ENABLE_SHARED=OFF -DLIBOMP_USE_INTERNODE_ALIGNMENT=ON -DLIBOMP_INSTALL_ALIASES=OFF && \
        cmake --build build --config Release -j 16 && \
        cmake --install build --prefix "$(pwd)/install" && \
        cp -a install/lib/libomp.a /install/usr/lib \
    ) && \
    rm -rf openmp-*


FROM stage1
COPY --from=builder /install /
USER dev
ENV GOPATH /home/dev/go
ENV PATH="/home/dev/go/bin:${PATH}"
RUN git config --global user.email "you@example.com" && \
    git config --global user.name "Your Name"
