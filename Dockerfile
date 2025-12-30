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
    echo 'IyEvYmluL2Jhc2gKCiMgQ29sb3IgZGVmaW5pdGlvbnMgKHJlYWRvbmx5IGZvciBjb21waWxlciBoaW50cykKcmVhZG9ubHkgQ19SRVNFVD0nXFtcZVswbVxdJwpyZWFkb25seSBDX0JPTEQ9J1xbXGVbMW1cXScKcmVhZG9ubHkgQ19VU0VSPSdcW1xlWzM4OzU7NTFtXF0nCnJlYWRvbmx5IENfSE9TVD0nXFtcZVszODs1OzIxM21cXScKcmVhZG9ubHkgQ19QQVRIPSdcW1xlWzM4OzU7MjI4bVxdJwpyZWFkb25seSBDX0dJVD0nXFtcZVszODs1OzE0MW1cXScKcmVhZG9ubHkgQ19HSVRfRElSVFk9J1xbXGVbMzg7NTsyMDhtXF0nCnJlYWRvbmx5IENfQlJBQ0tFVD0nXFtcZVszODs1OzI0NW1cXScKcmVhZG9ubHkgQ19QUk9NUFQ9J1xbXGVbMzg7NTs0Nm1cXScKcmVhZG9ubHkgQ19ST09UPSdcW1xlWzM4OzU7MTk2bVxdJwpyZWFkb25seSBDX1RJTUVfRkFTVD0nXFtcZVszODs1OzQ2bVxdJwpyZWFkb25seSBDX1RJTUVfU0xPVz0nXFtcZVszODs1OzIwOG1cXScKCiMgVGltZXIgdmFyaWFibGVzCl9fdGltZXJfc3RhcnQ9MApfX3RpbWVyX3Nob3c9IiIKX190aW1lcl9hY3RpdmU9MCAgIyBGbGFnIHRvIGluZGljYXRlIGlmIHdlJ3JlIHRpbWluZyBhIHJlYWwgY29tbWFuZAoKIyBEZWZpbmUgdGltZSBnZXR0ZXIgYmFzZWQgb24gYXZhaWxhYmxlIGZlYXR1cmVzCiMgQWx3YXlzIHJldHVybnMgZm9ybWF0OiBzZWNvbmRzLm1pY3Jvc2Vjb25kcyAoNiBkaWdpdHMpCmlmIFtbIC1uICIke0VQT0NIUkVBTFRJTUV9IiBdXTsgdGhlbgogICAgIyBCYXNoIDUuMCsgd2l0aCBtaWNyb3NlY29uZCBwcmVjaXNpb24gLSBhbHJlYWR5IGluIGNvcnJlY3QgZm9ybWF0CiAgICBfX2dldF90aW1lKCkgewogICAgICAgIHByaW50ZiAtdiBfX3RpbWVfcmVzdWx0ICclcycgIiR7RVBPQ0hSRUFMVElNRX0iCiAgICB9CmVsc2UKICAgICMgRmFsbGJhY2sgZm9yIG9sZGVyIGJhc2ggLSBjb252ZXJ0IG5hbm9zZWNvbmRzIHRvIG1pY3Jvc2Vjb25kcwogICAgX19nZXRfdGltZSgpIHsKICAgICAgICBsb2NhbCB0aW1lIHNlYyBucyB1cwogICAgICAgIHByaW50ZiAtdiB0aW1lICclKCVzKVQnIC0xIDI+L2Rldi9udWxsCiAgICAgICAgCiAgICAgICAgIyBUcnkgdG8gZ2V0IG5hbm9zZWNvbmRzIGlmIGF2YWlsYWJsZQogICAgICAgIGlmIGNvbW1hbmQgLXYgZGF0ZSAmPi9kZXYvbnVsbDsgdGhlbgogICAgICAgICAgICB0aW1lPSQoZGF0ZSArJXMuJU4gMj4vZGV2L251bGwpCiAgICAgICAgICAgIGlmIFtbICIkdGltZSIgPT0gKiIuIiogXV07IHRoZW4KICAgICAgICAgICAgICAgIHNlYz0iJHt0aW1lJS4qfSIKICAgICAgICAgICAgICAgIG5zPSIke3RpbWUjKi59IgogICAgICAgICAgICAgICAgdXM9IiR7bnM6MDo2fSIKICAgICAgICAgICAgICAgIHByaW50ZiAtdiBfX3RpbWVfcmVzdWx0ICclcy4lcycgIiRzZWMiICIkdXMiCiAgICAgICAgICAgICAgICByZXR1cm4KICAgICAgICAgICAgZmkKICAgICAgICBmaQogICAgICAgIAogICAgICAgICMgRmFsbGJhY2sgdG8gc2Vjb25kcyBvbmx5CiAgICAgICAgcHJpbnRmIC12IF9fdGltZV9yZXN1bHQgJyVzLjAwMDAwMCcgIiR0aW1lIgogICAgfQpmaQoKIyBQcmVleGVjOiBzdGFydCB0aW1lciBiZWZvcmUgY29tbWFuZCBleGVjdXRpb24KX19wcmVleGVjKCkgewogICAgbG9jYWwgY21kPSIkQkFTSF9DT01NQU5EIgogICAgCiAgICAjIEZhc3QgcmVqZWN0aW9uIG9mIGludGVybmFsIGNvbW1hbmRzIGFuZCBlbXB0eSBjb21tYW5kcwogICAgY2FzZSAiJGNtZCIgaW4KICAgICAgICAjIE91ciBpbnRlcm5hbCBmdW5jdGlvbnMKICAgICAgICBfX2J1aWxkX3Byb21wdCp8X19naXRfaW5mbyp8X19qb2JfY291bnQqfF9fZXhlY3V0aW9uX3RpbWUqfF9fdGltZXJfc3RvcCp8X19wcmVleGVjKnxfX2dldF90aW1lKnxfX2NhbGNfZWxhcHNlZF91cyp8X19zZXRfdGl0bGUqKQogICAgICAgICAgICByZXR1cm4gOzsKICAgICAgICAjIEJhc2ggbm8tb3AgYW5kIGRlY2xhcmF0aW9ucwogICAgICAgIDp8OlwgKnxkZWNsYXJlXCAqfGxvY2FsXCAqfGV4cG9ydFwgKnxyZWFkb25seVwgKikKICAgICAgICAgICAgcmV0dXJuIDs7CiAgICAgICAgIyBUZXN0IGFuZCBjb25kaXRpb25hbHMgKGludGVybmFsIHRvIGxvb3BzL3NjcmlwdHMpCiAgICAgICAgXFtcWyp8XChcKCp8aWZcICp8dGhlbip8ZWxzZSp8ZmkqfGNhc2UqfGVzYWMqfGRvXCAqfGRvbmUqKQogICAgICAgICAgICByZXR1cm4gOzsKICAgICAgICAjIEVtcHR5CiAgICAgICAgIiIpCiAgICAgICAgICAgIHJldHVybiA7OwogICAgZXNhYwogICAgCiAgICAjIFNraXAgaWYgY29tbWFuZCBpcyBqdXN0IHdoaXRlc3BhY2UKICAgIFtbIC16ICIke2NtZC8vIC99IiBdXSAmJiByZXR1cm4KICAgICMgQ29tbWVudHMKICAgIFtbICIkY21kIiA9fiBeW1s6c3BhY2U6XV0qIyBdXSAmJiByZXR1cm4KICAgIAogICAgIyBGaWx0ZXIgc3RhbmRhbG9uZSB2YXJpYWJsZSBhc3NpZ25tZW50cwogICAgIyBTdHJhdGVneTogUmVtb3ZlIGFsbCBWQVI9dmFsdWUgcGF0dGVybnMsIHNlZSBpZiBhbnl0aGluZyBpcyBsZWZ0CiAgICBpZiBbWyAiJGNtZCIgPX4gXlthLXpBLVpfXVthLXpBLVowLTlfXSo9IF1dOyB0aGVuCiAgICAgICAgbG9jYWwgcmVtYWluaW5nPSIkY21kIgogICAgICAgICMgU3RyaXAgYWxsIFZBUj12YWx1ZSBwYXR0ZXJucyBmcm9tIHRoZSBiZWdpbm5pbmcKICAgICAgICB3aGlsZSBbWyAiJHJlbWFpbmluZyIgPX4gXlthLXpBLVpfXVthLXpBLVowLTlfXSo9W15bOnNwYWNlOl1dKltbOnNwYWNlOl1dKiBdXTsgZG8KICAgICAgICAgICAgcmVtYWluaW5nPSIke3JlbWFpbmluZyMke0JBU0hfUkVNQVRDSFswXX19IgogICAgICAgIGRvbmUKICAgICAgICAjIElmIG5vdGhpbmcgbGVmdCwgaXQgd2FzIGp1c3QgYXNzaWdubWVudHMKICAgICAgICBbWyAteiAiJHJlbWFpbmluZyIgXV0gJiYgcmV0dXJuCiAgICBmaQogICAgCiAgICAjIElNUE9SVEFOVDogT25seSBzdGFydCB0aW1lciBpZiBub3QgYWxyZWFkeSB0aW1pbmcKICAgICMgVGhpcyBwcmV2ZW50cyByZXNldHRpbmcgZHVyaW5nIGNvbXBvdW5kIGNvbW1hbmRzIChmb3Ivd2hpbGUvaWYgbG9vcHMpCiAgICBpZiBbWyAkX190aW1lcl9hY3RpdmUgLWVxIDAgXV07IHRoZW4KICAgICAgICBfX3RpbWVyX2FjdGl2ZT0xCiAgICAgICAgX19nZXRfdGltZQogICAgICAgIF9fdGltZXJfc3RhcnQ9IiRfX3RpbWVfcmVzdWx0IgogICAgZmkKfQoKIyBDYWxjdWxhdGUgZWxhcHNlZCB0aW1lIGluIG1pY3Jvc2Vjb25kcyAocHVyZSBiYXNoIGFyaXRobWV0aWMpCl9fY2FsY19lbGFwc2VkX3VzKCkgewogICAgbG9jYWwgc3RhcnQ9IiQxIiBlbmQ9IiQyIgogICAgbG9jYWwgc3RhcnRfc2VjIHN0YXJ0X3VzIGVuZF9zZWMgZW5kX3VzCiAgICAKICAgICMgU3BsaXQgdXNpbmcgcGFyYW1ldGVyIGV4cGFuc2lvbiAobm8gc3Vic2hlbGxzKQogICAgc3RhcnRfc2VjPSIke3N0YXJ0JS4qfSIKICAgIHN0YXJ0X3VzPSIke3N0YXJ0IyoufSIKICAgIGVuZF9zZWM9IiR7ZW5kJS4qfSIKICAgIGVuZF91cz0iJHtlbmQjKi59IgogICAgCiAgICAjIFB1cmUgYXJpdGhtZXRpYwogICAgcHJpbnRmIC12IF9fZWxhcHNlZF9yZXN1bHQgJyVkJyAiJCgoIChlbmRfc2VjIC0gc3RhcnRfc2VjKSAqIDEwMDAwMDAgKyAxMCMkZW5kX3VzIC0gMTAjJHN0YXJ0X3VzICkpIgp9CgojIFN0b3AgdGltZXIgYW5kIGZvcm1hdCBvdXRwdXQgd2l0aCBmdWxsIHByZWNpc2lvbgpfX3RpbWVyX3N0b3AoKSB7CiAgICAjIE9ubHkgcHJvY2VzcyBpZiB3ZSB3ZXJlIGFjdGl2ZWx5IHRpbWluZyBhIGNvbW1hbmQKICAgIGlmIFtbICRfX3RpbWVyX2FjdGl2ZSAtZXEgMCB8fCAiJF9fdGltZXJfc3RhcnQiID09ICIwIiB8fCAteiAiJF9fdGltZXJfc3RhcnQiIF1dOyB0aGVuCiAgICAgICAgX190aW1lcl9zaG93PSIiCiAgICAgICAgX190aW1lcl9hY3RpdmU9MAogICAgICAgIF9fdGltZXJfc3RhcnQ9MAogICAgICAgIHJldHVybgogICAgZmkKICAgIAogICAgX19nZXRfdGltZQogICAgbG9jYWwgdGltZXJfZW5kPSIkX190aW1lX3Jlc3VsdCIKICAgIF9fY2FsY19lbGFwc2VkX3VzICIkX190aW1lcl9zdGFydCIgIiR0aW1lcl9lbmQiCiAgICBsb2NhbCBlbGFwc2VkX3VzPSIkX19lbGFwc2VkX3Jlc3VsdCIKICAgIAogICAgIyBSZXNldCB0aW1lciBzdGF0ZQogICAgX190aW1lcl9zdGFydD0wCiAgICBfX3RpbWVyX2FjdGl2ZT0wCiAgICAKICAgICMgRm9ybWF0IGJhc2VkIG9uIG1hZ25pdHVkZSAocHVyZSBiYXNoLCBubyBiYy9hd2spCiAgICBpZiAoKCBlbGFwc2VkX3VzIDwgMTAwMCApKTsgdGhlbgogICAgICAgICMgPCAxbXM6IHNob3cgbWljcm9zZWNvbmRzCiAgICAgICAgX190aW1lcl9zaG93PSIke2VsYXBzZWRfdXN9wrVzIgogICAgZWxpZiAoKCBlbGFwc2VkX3VzIDwgMTAwMDAwMCApKTsgdGhlbgogICAgICAgICMgPCAxczogc2hvdyBtaWxsaXNlY29uZHMgd2l0aCBkZWNpbWFscwogICAgICAgIGxvY2FsIG1zPSQoKCBlbGFwc2VkX3VzIC8gMTAwMCApKQogICAgICAgIGxvY2FsIGZyYWM9JCgoIGVsYXBzZWRfdXMgJSAxMDAwICkpCiAgICAgICAgaWYgKCggbXMgPCAxMCApKTsgdGhlbgogICAgICAgICAgICBwcmludGYgLXYgX190aW1lcl9zaG93ICclZC4lMDJkbXMnICIkbXMiICIkKChmcmFjIC8gMTApKSIKICAgICAgICBlbGlmICgoIG1zIDwgMTAwICkpOyB0aGVuCiAgICAgICAgICAgIHByaW50ZiAtdiBfX3RpbWVyX3Nob3cgJyVkLiUwMWRtcycgIiRtcyIgIiQoKGZyYWMgLyAxMDApKSIKICAgICAgICBlbHNlCiAgICAgICAgICAgIF9fdGltZXJfc2hvdz0iJHttc31tcyIKICAgICAgICBmaQogICAgZWxpZiAoKCBlbGFwc2VkX3VzIDwgNjAwMDAwMDAgKSk7IHRoZW4KICAgICAgICAjIDwgMW1pbjogc2hvdyBzZWNvbmRzIHdpdGggMiBkZWNpbWFscwogICAgICAgIGxvY2FsIHRvdGFsX21zPSQoKCBlbGFwc2VkX3VzIC8gMTAwMCApKQogICAgICAgIGxvY2FsIHNlY29uZHM9JCgoIHRvdGFsX21zIC8gMTAwMCApKQogICAgICAgIGxvY2FsIG1zPSQoKCB0b3RhbF9tcyAlIDEwMDAgKSkKICAgICAgICBwcmludGYgLXYgX190aW1lcl9zaG93ICclZC4lMDJkcycgIiRzZWNvbmRzIiAiJCgobXMgLyAxMCkpIgogICAgZWxpZiAoKCBlbGFwc2VkX3VzIDwgMzYwMDAwMDAwMCApKTsgdGhlbgogICAgICAgICMgPCAxaDogc2hvdyBtaW51dGVzIGFuZCBzZWNvbmRzCiAgICAgICAgbG9jYWwgdG90YWxfc2Vjcz0kKCggZWxhcHNlZF91cyAvIDEwMDAwMDAgKSkKICAgICAgICBsb2NhbCBtPSQoKCB0b3RhbF9zZWNzIC8gNjAgKSkKICAgICAgICBsb2NhbCBzPSQoKCB0b3RhbF9zZWNzICUgNjAgKSkKICAgICAgICBfX3RpbWVyX3Nob3c9IiR7bX1tJHtzfXMiCiAgICBlbHNlCiAgICAgICAgIyA+PSAxaAogICAgICAgIGxvY2FsIHRvdGFsX3NlY3M9JCgoIGVsYXBzZWRfdXMgLyAxMDAwMDAwICkpCiAgICAgICAgbG9jYWwgaD0kKCggdG90YWxfc2VjcyAvIDM2MDAgKSkKICAgICAgICBsb2NhbCBtPSQoKCAodG90YWxfc2VjcyAlIDM2MDApIC8gNjAgKSkKICAgICAgICBsb2NhbCBzPSQoKCB0b3RhbF9zZWNzICUgNjAgKSkKICAgICAgICBfX3RpbWVyX3Nob3c9IiR7aH1oJHttfW0ke3N9cyIKICAgIGZpCn0KCiMgRGlzcGxheSBleGVjdXRpb24gdGltZSB3aXRoIGNvbG9yIGNvZGluZyAobm8gc3Vic2hlbGxzKQpfX2V4ZWN1dGlvbl90aW1lKCkgewogICAgW1sgLXogIiRfX3RpbWVyX3Nob3ciIF1dICYmIHJldHVybgogICAgCiAgICBsb2NhbCB0aW1lX2NvbG9yCiAgICBjYXNlICIkX190aW1lcl9zaG93IiBpbgogICAgICAgICrCtXN8Ki4/P21zKSB0aW1lX2NvbG9yPSIkQ19USU1FX0ZBU1QiIDs7CiAgICAgICAgKm1zKSB0aW1lX2NvbG9yPSIkQ19USU1FX0ZBU1QiIDs7CiAgICAgICAgKmgqfCptKikgdGltZV9jb2xvcj0iJENfVElNRV9TTE9XIiA7OwogICAgICAgICpzKQogICAgICAgICAgICBsb2NhbCBzZWNzPSIke19fdGltZXJfc2hvdyVzfSIKICAgICAgICAgICAgc2Vjcz0iJHtzZWNzJS4qfSIKICAgICAgICAgICAgKCggc2VjcyA+PSA1ICkpICYmIHRpbWVfY29sb3I9IiRDX1RJTUVfU0xPVyIgfHwgdGltZV9jb2xvcj0iJENfVElNRV9GQVNUIgogICAgICAgICAgICA7OwogICAgZXNhYwogICAgCiAgICBwcmludGYgJyVzJyAiJHtDX0JSQUNLRVR9WyR7dGltZV9jb2xvcn0ke19fdGltZXJfc2hvd30ke0NfQlJBQ0tFVH1dJHtDX1JFU0VUfSAiCn0KCiMgR2l0IGluZm8gd2l0aCBlYXJseSBleGl0IG9wdGltaXphdGlvbgpfX2dpdF9pbmZvKCkgewogICAgIyBGYXN0IHBhdGg6IGNoZWNrIGlmIHdlJ3JlIGluIGEgZ2l0IHJlcG8gYmVmb3JlIGNhbGxpbmcgZ2l0CiAgICAjIFdhbGsgdXAgZGlyZWN0b3J5IHRyZWUgbG9va2luZyBmb3IgLmdpdAogICAgbG9jYWwgZGlyPSIkUFdEIgogICAgd2hpbGUgW1sgLW4gIiRkaXIiICYmICIkZGlyIiAhPSAiLyIgXV07IGRvCiAgICAgICAgW1sgLWQgIiRkaXIvLmdpdCIgXV0gJiYgYnJlYWsKICAgICAgICBkaXI9IiR7ZGlyJS8qfSIKICAgIGRvbmUKICAgIAogICAgIyBOb3QgaW4gYSBnaXQgcmVwbwogICAgW1sgLXogIiRkaXIiIHx8ICIkZGlyIiA9PSAiLyIgXV0gJiYgcmV0dXJuCiAgICAKICAgICMgR2V0IGJyYW5jaCBuYW1lIChvbmx5IGV4dGVybmFsIGNvbW1hbmQgd2UgY2FuJ3QgYXZvaWQpCiAgICBsb2NhbCBicmFuY2gKICAgIGJyYW5jaD0kKGdpdCBzeW1ib2xpYy1yZWYgLS1zaG9ydCBIRUFEIDI+L2Rldi9udWxsKSB8fCByZXR1cm4KICAgIAogICAgIyBGYXN0IGRpcnR5IGNoZWNrIHVzaW5nIGdpdCBpbnRlcm5hbHMKICAgIGxvY2FsIGRpcnR5PSIiCiAgICBpZiAhIGdpdCBkaWZmLWluZGV4IC0tcXVpZXQgSEVBRCAyPi9kZXYvbnVsbDsgdGhlbgogICAgICAgIGRpcnR5PSIke0NfR0lUX0RJUlRZfSoke0NfUkVTRVR9IgogICAgZmkKICAgIAogICAgcHJpbnRmICclcycgIiAke0NfQlJBQ0tFVH1bJHtDX0dJVH0ke2JyYW5jaH0ke2RpcnR5fSR7Q19CUkFDS0VUfV0ke0NfUkVTRVR9Igp9CgojIEpvYiBjb3VudCB1c2luZyBwdXJlIGJhc2ggKG5vIGV4dGVybmFsIHdjKQpfX2pvYl9jb3VudCgpIHsKICAgIGxvY2FsIGNvdW50PTAKICAgIAogICAgIyBVc2UgYmFzaCBidWlsdC1pbiB0byBjb3VudCBqb2JzCiAgICB3aGlsZSByZWFkIC1yOyBkbwogICAgICAgICgoIGNvdW50KysgKSkKICAgIGRvbmUgPCA8KGpvYnMgLXApCiAgICAKICAgICgoIGNvdW50ID4gMCApKSAmJiBwcmludGYgJyVzJyAiICR7Q19CUkFDS0VUfVske0NfVVNFUn0ke2NvdW50feKamSR7Q19CUkFDS0VUfV0ke0NfUkVTRVR9Igp9CgojIEJ1aWxkIHByb21wdCB3aXRoIG1pbmltYWwgc3Vic2hlbGxzCl9fYnVpbGRfcHJvbXB0KCkgewogICAgbG9jYWwgZXhpdF9zdGF0dXM9JD8KICAgIAogICAgIyBTdG9wIHRpbWVyIGFuZCByZXNldCBhbGwgc3RhdGUKICAgIF9fdGltZXJfc3RvcAogICAgX190aW1lcl9zdGFydD0wCiAgICBfX3RpbWVyX2FjdGl2ZT0wCiAgICAKICAgICMgRGV0ZXJtaW5lIGNvbG9ycy9zeW1ib2xzIHVzaW5nIGFyaXRobWV0aWMKICAgIGxvY2FsIHN0YXR1c19pY29uIHByb21wdF9zeW1ib2wKICAgIGlmICgoIGV4aXRfc3RhdHVzID09IDAgKSk7IHRoZW4KICAgICAgICBzdGF0dXNfaWNvbj0iJHtDX1BST01QVH3inJMke0NfUkVTRVR9IgogICAgZWxzZQogICAgICAgIHN0YXR1c19pY29uPSIke0NfUk9PVH3inJcke0NfUkVTRVR9IgogICAgZmkKICAgIAogICAgaWYgKCggRVVJRCA9PSAwICkpOyB0aGVuCiAgICAgICAgcHJvbXB0X3N5bWJvbD0iJHtDX1JPT1R9IyR7Q19SRVNFVH0iCiAgICBlbHNlCiAgICAgICAgcHJvbXB0X3N5bWJvbD0iJHtDX1BST01QVH3ina8ke0NfUkVTRVR9IgogICAgZmkKICAgIAogICAgIyBCdWlsZCBQUzEgaW4gc2luZ2xlIG9wZXJhdGlvbiAobm8gaW50ZXJtZWRpYXRlIGFzc2lnbm1lbnRzKQogICAgUFMxPSIkKF9fZXhlY3V0aW9uX3RpbWUpJHtzdGF0dXNfaWNvbn0gJHtDX0JPTER9JHtDX1VTRVJ9XHUke0NfUkVTRVR9JHtDX0JSQUNLRVR9QCR7Q19SRVNFVH0ke0NfQk9MRH0ke0NfSE9TVH1caCR7Q19SRVNFVH0ke0NfQlJBQ0tFVH06JHtDX1JFU0VUfSR7Q19CT0xEfSR7Q19QQVRIfVx3JHtDX1JFU0VUfSQoX19naXRfaW5mbykkKF9fam9iX2NvdW50KSAke3Byb21wdF9zeW1ib2x9ICIKfQoKIyBTZXQgdXAgREVCVUcgdHJhcCBmb3IgcHJlZXhlYwp0cmFwICdfX3ByZWV4ZWMnIERFQlVHCgojIFNldCBQUk9NUFRfQ09NTUFORApQUk9NUFRfQ09NTUFORD1fX2J1aWxkX3Byb21wdAoKIyBUZXJtaW5hbCB0aXRsZSB1c2luZyBwcmludGYgKG5vIGVjaG8pCmNhc2UgIiRURVJNIiBpbgogICAgeHRlcm0qfHJ4dnQqfHNjcmVlbiopCiAgICAgICAgX19zZXRfdGl0bGUoKSB7CiAgICAgICAgICAgIGxvY2FsIHRpdGxlPSIke1BXRC8jJEhPTUUvXH59IgogICAgICAgICAgICBwcmludGYgJ1wwMzNdMDslc0AlczogJXNcMDA3JyAiJHtVU0VSfSIgIiR7SE9TVE5BTUUlJS4qfSIgIiR0aXRsZSIKICAgICAgICB9CiAgICAgICAgUFJPTVBUX0NPTU1BTkQ9Il9fYnVpbGRfcHJvbXB0OyBfX3NldF90aXRsZSIKICAgICAgICA7Owplc2FjCg==' \
            | base64 -d > /etc/bash/bashrc.d/ps1.bash && \
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
CMD ["/bin/bash"]
