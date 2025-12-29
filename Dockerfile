FROM chimeralinux/chimera AS stage1

RUN apk add --upgrade --no-interactive \
        bash-completion opendoas base-cbuild-bootstrap base-kernel-devel base-devel flatpak-builder go cargo \
        rust ruby typescript yarn java-jdk-openjdk21-default python-meta python-hatch_vcs vala opencv ffmpeg \
        curl wget2 git \
        gawk patchelf \
        winetricks lldb gdb binutils ccache valgrind strace tcpdump clang-tools-extra tmux htop zip cloud-utils \
        util-linux subversion mercurial base-full '!base-full-sound' '!base-full-session' '!base-full-man' \
        '!base-full-locale' '!base-full-kernel' '!base-full-fonts' '!base-full-firmware' chimera-repo-user \
        && \
    apk add --no-interactive uv cppcheck hare sysstat maven python-matplotlib \
        $(apk list -q util-linux-* | \
                sed -e /util-linux-.*-.*/d -e /-man/d -e /-doc/d -e /-common/d -e /-bashcomp/d) \
        $(apk list -q *-static | sed -e /-cross-/d -e /-mallocng-/d) && \
    apk add --no-interactive libgcc-chimera libatomic-chimera && \
    rm -rf /var/cache/apk/* && \
    ln -srv /bin/doas /bin/sudo && \
    printf '%s\n' '' '# Give users in the wheelnopw group access.' 'permit nopass :wheelnopw' >> /etc/doas.conf && \
    if [ ! -e /etc/bash/bashrc ] ; then \
        printf '%s\n' 'for script in /etc/bash/bashrc.d/*; do' '    [ -f "$script" ] && . "$script"' 'done' \
                > /etc/bash/bashrc ; \
    fi && \
    echo 'IyEvYmluL2Jhc2gKCiMgQ29sb3IgZGVmaW5pdGlvbnMKQ09MT1JfUkVTRVQ9J1xbXDAzM1swbVxdJwpDT0xPUl9CT0xEPSdcW1wwMzNbMW1cXScKQ09MT1JfVVNFUj0nXFtcMDMzWzM4OzU7NTFtXF0nICAgICAgICMgQnJpZ2h0IGN5YW4KQ09MT1JfSE9TVD0nXFtcMDMzWzM4OzU7MjEzbVxdJyAgICAgICMgUGluawpDT0xPUl9QQVRIPSdcW1wwMzNbMzg7NTsyMjhtXF0nICAgICAgIyBCcmlnaHQgeWVsbG93CkNPTE9SX0dJVD0nXFtcMDMzWzM4OzU7MTQxbVxdJyAgICAgICAjIFB1cnBsZQpDT0xPUl9HSVRfRElSVFk9J1xbXDAzM1szODs1OzIwOG1cXScgIyBPcmFuZ2UKQ09MT1JfQlJBQ0tFVD0nXFtcMDMzWzM4OzU7MjQ1bVxdJyAgICMgR3JheQpDT0xPUl9QUk9NUFQ9J1xbXDAzM1szODs1OzQ2bVxdJyAgICAgIyBCcmlnaHQgZ3JlZW4KQ09MT1JfUk9PVD0nXFtcMDMzWzM4OzU7MTk2bVxdJyAgICAgICMgQnJpZ2h0IHJlZApDT0xPUl9USU1FPSdcW1wwMzNbMzg7NTsyNDNtXF0nICAgICAgIyBEYXJrIGdyYXkKCiMgRnVuY3Rpb24gdG8gZ2V0IGN1cnJlbnQgZ2l0IGJyYW5jaCB3aXRoIHN0YXR1cwpfX2dpdF9pbmZvKCkgewogICAgbG9jYWwgYnJhbmNoIGRpcnR5CiAgICBpZiBicmFuY2g9JChnaXQgc3ltYm9saWMtcmVmIC0tc2hvcnQgSEVBRCAyPi9kZXYvbnVsbCk7IHRoZW4KICAgICAgICAjIENoZWNrIGlmIHRoZXJlIGFyZSB1bmNvbW1pdHRlZCBjaGFuZ2VzCiAgICAgICAgaWYgISBnaXQgZGlmZiAtLXF1aWV0IDI+L2Rldi9udWxsIHx8ICEgZ2l0IGRpZmYgLS1jYWNoZWQgLS1xdWlldCAyPi9kZXYvbnVsbDsgdGhlbgogICAgICAgICAgICBkaXJ0eT0iJHtDT0xPUl9HSVRfRElSVFl9KiR7Q09MT1JfUkVTRVR9IgogICAgICAgIGZpCiAgICAgICAgZWNobyAiICR7Q09MT1JfQlJBQ0tFVH1bJHtDT0xPUl9HSVR9JHticmFuY2h9JHtkaXJ0eX0ke0NPTE9SX0JSQUNLRVR9XSR7Q09MT1JfUkVTRVR9IgogICAgZmkKfQoKIyBGdW5jdGlvbiB0byBnZXQgam9iIGNvdW50Cl9fam9iX2NvdW50KCkgewogICAgbG9jYWwgam9ic19jb3VudD0kKGpvYnMgLXAgfCB3YyAtbCkKICAgIGlmIFsgIiRqb2JzX2NvdW50IiAtZ3QgMCBdOyB0aGVuCiAgICAgICAgZWNobyAiICR7Q09MT1JfQlJBQ0tFVH1bJHtDT0xPUl9VU0VSfSR7am9ic19jb3VudH3impkke0NPTE9SX0JSQUNLRVR9XSR7Q09MT1JfUkVTRVR9IgogICAgZmkKfQoKIyBCdWlsZCB0aGUgcHJvbXB0Cl9fYnVpbGRfcHJvbXB0KCkgewogICAgbG9jYWwgZXhpdF9zdGF0dXM9JD8KICAgIAogICAgIyBFeGl0IHN0YXR1cyBpbmRpY2F0b3IKICAgIGxvY2FsIHN0YXR1c19pY29uCiAgICBpZiBbICRleGl0X3N0YXR1cyAtZXEgMCBdOyB0aGVuCiAgICAgICAgc3RhdHVzX2ljb249IiR7Q09MT1JfUFJPTVBUfeKckyR7Q09MT1JfUkVTRVR9IgogICAgZWxzZQogICAgICAgIHN0YXR1c19pY29uPSIke0NPTE9SX1JPT1R94pyXJHtDT0xPUl9SRVNFVH0iCiAgICBmaQogICAgCiAgICAjIFByb21wdCBzeW1ib2wgKGRpZmZlcmVudCBmb3Igcm9vdCkKICAgIGxvY2FsIHByb21wdF9zeW1ib2wKICAgIGlmIFsgIiRFVUlEIiAtZXEgMCBdOyB0aGVuCiAgICAgICAgcHJvbXB0X3N5bWJvbD0iJHtDT0xPUl9ST09UfSMke0NPTE9SX1JFU0VUfSIKICAgIGVsc2UKICAgICAgICBwcm9tcHRfc3ltYm9sPSIke0NPTE9SX1BST01QVH3ina8ke0NPTE9SX1JFU0VUfSIKICAgIGZpCiAgICAKICAgICMgQnVpbGQgc2luZ2xlLWxpbmUgcHJvbXB0OiBbdGltZV0gc3RhdHVzIHVzZXJAaG9zdDpwYXRoIFtnaXRdIFtqb2JzXSDina8KICAgIFBTMT0iJHtDT0xPUl9CUkFDS0VUfVske0NPTE9SX1RJTUV9XHQke0NPTE9SX0JSQUNLRVR9XSR7Q09MT1JfUkVTRVR9ICIKICAgIFBTMSs9IiR7c3RhdHVzX2ljb259ICIKICAgIFBTMSs9IiR7Q09MT1JfQk9MRH0ke0NPTE9SX1VTRVJ9XHUke0NPTE9SX1JFU0VUfSIKICAgIFBTMSs9IiR7Q09MT1JfQlJBQ0tFVH1AJHtDT0xPUl9SRVNFVH0iCiAgICBQUzErPSIke0NPTE9SX0JPTER9JHtDT0xPUl9IT1NUfVxoJHtDT0xPUl9SRVNFVH0iCiAgICBQUzErPSIke0NPTE9SX0JSQUNLRVR9OiR7Q09MT1JfUkVTRVR9IgogICAgUFMxKz0iJHtDT0xPUl9CT0xEfSR7Q09MT1JfUEFUSH1cdyR7Q09MT1JfUkVTRVR9IgogICAgUFMxKz0iJChfX2dpdF9pbmZvKSIKICAgIFBTMSs9IiQoX19qb2JfY291bnQpIgogICAgUFMxKz0iICR7cHJvbXB0X3N5bWJvbH0gIgp9CgojIFNldCBQUk9NUFRfQ09NTUFORCB0byB1cGRhdGUgUFMxIGJlZm9yZSBlYWNoIHByb21wdApQUk9NUFRfQ09NTUFORD1fX2J1aWxkX3Byb21wdAoKIyBTZXQgdGVybWluYWwgdGl0bGUgdG8gdXNlckBob3N0OmRpcgpjYXNlICIkVEVSTSIgaW4KeHRlcm0qfHJ4dnQqfHNjcmVlbiopCiAgICBQUk9NUFRfQ09NTUFORD0iX19idWlsZF9wcm9tcHQ7ICInZWNobyAtbmUgIlwwMzNdMDske1VTRVJ9QCR7SE9TVE5BTUV9OiAke1BXRH1cMDA3IicKICAgIDs7CiopCiAgICA7Owplc2FjCg==' \
            > /etc/bash/bashrc.d/ps1.bash && \
    groupadd -r wheelnopw && \
    useradd -m -G wheelnopw -s /bin/bash dev


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
            CFLAGS="-fPIC -g0 -O3 -pipe" CC=gcc CXX=g++ "${GCC_SOURCE}/libstdc++-v3/configure" \
                --prefix=/usr --disable-werror --enable-shared --disable-static && \
        make -j$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4) && \
        make install DESTDIR="$(pwd)/install" && \
        cp -a install/usr/lib/*.* /install/usr/lib && \
        rm -f /install/usr/lib/libstdc++.so && \
        BUILD_DIR="$(pwd)/libgcc-build" && \
        mkdir -p "${BUILD_DIR}" && \
#        cd "${BUILD_DIR}" && \
#        CXXFLAGS="-fPIC -g0 -O3 -pipe -nostdinc++" CFLAGS="-fPIC -g0 -O3 -pipe" CC=gcc CXX=g++ "${GCC_SOURCE}/configure" \
#            --prefix=/usr --enable-shared --enable-static --disable-bootstrap --disable-multilib && \
#        make all-target-libgcc -j$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 4) && \
#        make install-strip-target-libgcc DESTDIR="$(pwd)/install" && \
#        cp install/usr/lib/gcc/x86_64-pc-linux-musl/15.2.0/libgcc* /usr/lib/gcc/*/*.0 && \
        : \
    ) && \
    rm -rf gcc-* libstdcxx-build libgcc-build && \
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
