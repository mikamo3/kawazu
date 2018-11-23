ARG bash_var=latest
FROM bash:${bash_var}
WORKDIR /tmp
RUN adduser -s /uer/local/bin/bash -D kawazu
RUN apk update && apk add --no-cache git xz expect
RUN wget "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz" && \
  tar --xz -xvf shellcheck-stable.linux.x86_64.tar.xz && \
  cp shellcheck-stable/shellcheck /usr/bin/ && \
  rm -rf shellcheck-stable* && \
  git clone https://github.com/bats-core/bats-core.git && \
  cd bats-core && \
  ./install.sh /usr/local && \
  cd ../ && \
  rm -rf bats-core
ADD bin /tmp/kawazu/bin
ADD lib /tmp/kawazu/lib
ADD test /tmp/kawazu/test
USER kawazu
CMD ["/tmp/kawazu/test/run_tests"]
