FROM ubuntu:focal

# unminimize
ENV DEBIAN_FRONTEND=noninteractive
RUN yes | unminimize

# utf-8 locale
RUN apt-get update \
    && apt-get install -qq locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# add ros 2 sources
RUN apt-get install -qq curl gnupg2 lsb-release \
    && curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc \
        | apt-key add - \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && apt-get update

# install ros 2
RUN apt-get install -qq ros-foxy-desktop

# install openssh-server
RUN apt-get install -qq openssh-server \
    && mkdir /var/run/sshd

# install some more useful things
RUN apt-get install -qq \
        python3-pip \
        sudo \
        tmux \
    && pip3 install -U argcomplete

# create unprivileged user
RUN useradd -m -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/ubuntu \
    && mkdir -p -m 700 /home/ubuntu/.ssh \
    && chown -R ubuntu:ubuntu /home/ubuntu/.ssh \
    && echo "\nsource /opt/ros/foxy/setup.bash" >> /home/ubuntu/.bashrc

ENV DEBIAN_FRONTEND=
COPY bin/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
