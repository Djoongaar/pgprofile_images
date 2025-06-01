FROM ubuntu

ENV HOMEDIR     "/home/postgres"
ENV SOURCEDIR   "$HOMEDIR/source"
ENV PATH        "$PATH:/bin/bash:/usr/bin/bash:$SOURCEDIR/pg_validate_extupgrade/target/release"

# explicitly set user/group IDs
RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir="$HOMEDIR" --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p "$HOMEDIR"; \
	chown -R postgres:postgres "$HOMEDIR"

RUN set -ex; \
	apt-get update; \
	apt-get install -y --reinstall ca-certificates; \
	apt-get install -y --no-install-recommends \
	gnupg \
    libpq-dev \
    bash  \
    diffutils  \
    git  \
    rustc  \
    cargo  \
    python3 \
    python3-pip \
    postgresql-client  \
    openssh-server; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    pip install  --no-cache-dir --upgrade --break-system-packages \
    psycopg2-binary \
    asyncpg \
    SQLAlchemy

RUN set -eux; \
    mkdir -p "$HOMEDIR"; \
	mkdir -p "${SOURCEDIR}"; \
    cd "${SOURCEDIR}" && \
    git clone https://github.com/rjuju/pg_validate_extupgrade.git && \
    cd "${SOURCEDIR}/pg_validate_extupgrade" && \
    cargo update && \
    cargo build --release;

# SSH connection config \
RUN set -eux; \
	\
    ssh-keygen -A && \
    echo "AllowTCPForwarding yes" >> /etc/ssh/sshd_config  && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config  && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

RUN chown -R postgres:postgres "$HOMEDIR"
RUN chmod g+s "$HOMEDIR"

EXPOSE 22

CMD ["bash"]