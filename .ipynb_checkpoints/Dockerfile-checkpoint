USER root

#
# Set version, zip password, and download url
#
ARG NONMEM_MAJOR_VERSION=7
ARG NONMEM_MINOR_VERSION=4
ARG NONMEM_PATCH_VERSION=1
ARG NONMEM_ZIP_PASS_74=zorx7bqRT
ENV NONMEM_URL=https://nonmem.iconplc.com/nonmem${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION}${NONMEM_PATCH_VERSION}/NONMEM${NONMEM_MAJOR_VERSION}.${NONMEM_MINOR_VERSION}.${NONMEM_PATCH_VERSION}.zip

# Install dependencies (then clean up the image as much as possible)
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        libssh-dev \
        ca-certificates \
        gfortran \
        libmpich-dev \
        mpich \
        wget \
        unzip \
    && rm -rf \
        /var/lib/apt/lists/ \
        /var/cache/apt/archives/ \
	    /usr/share/doc/ \
	    /usr/share/man/ \
	    /usr/share/locale/

# Install NONMEM and then clean out unnecessary files to keep image smaller
RUN cd /tmp \
    && wget --no-verbose --no-check-certificate -O NONMEM.zip ${NONMEM_URL} \
    && unzip -P ${NONMEM_ZIP_PASS_74} NONMEM.zip \
    && cd /tmp/nm${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION}${NONMEM_PATCH_VERSION}CD \
    && bash SETUP${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION} \
        /tmp/nm${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION}${NONMEM_PATCH_VERSION}CD \
        /opt/nm \
        gfortran \
        y \
        /usr/bin/ar \
        same \
        rec \
        q \
        unzip \
        nonmem${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION}e.zip \
        nonmem${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION}r.zip \
    && rm -r /tmp/* \
    && rm /opt/nm/mpi/mpi_ling/libmpich.a \
    && ln -s /usr/lib/mpich/lib/libmpich.a /opt/nm/mpi/mpi_ling/libmpich.a \
    && (cd /opt/nm && \
        rm -rf \
            examples/ \
            guides/ \
            help/ \
            html/ \
            *.pdf \
            *.txt \
            *.zip \
            install* \
            nonmem.lic \
            SETUP* \
            unzip.SunOS \
            unzip.exe \
            mpi/mpi_lini \
            mpi/mpi_wing \
            mpi/mpi_wini \
            run/*.bat \
            run/*.EXE \
            run/*.LNK \
            run/CONTROL* \
            run/DATA* \
            run/REPORT* \
            run/fpiwin* \
            run/mpiwin* \
            run/FCON \
            run/FDATA \
            run/FREPORT \
            run/FSIZES \
            run/FSTREAM \
            run/FSUBS \
            run/INTER \
            run/computername.exe \
            run/garbage.out \
            run/gfortran.txt \
            run/nmhelp.exe \
            run/psexec.exe \
            runfiles/GAWK.EXE \
            runfiles/GREP.EXE \
            runfiles/computername.exe \
            runfiles/fpiwin* \
            runfiles/mpiwin* \
            runfiles/nmhelp.exe \
            runfiles/psexec.exe \
            util/*.bat \
            util/*~ \
            util/CONTROL* \
            util/F* \
            util/DATA3 \
            util/ERROR1 \
            util/INTER \
            util/finish_Darwin* \
            util/finish_Linux_f95 \
            util/finish_Linux_g95 \
            util/finish_SunOS*)

ENV PATH /opt/nm/run:$PATH

# link nmfe to specific version so we can use a consistent ENTRYPOINT
RUN ln -s /opt/nm/run/nmfe${NONMEM_MAJOR_VERSION}${NONMEM_MINOR_VERSION} /opt/nm/run/nmfe

# expects in and out files specified at runtime
ENTRYPOINT ["/opt/nm/run/nmfe"]

# cpanm and PsN requirements
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
		ca-certificates \
		gcc \
		build-essential \
		curl \
		expect \
    && rm -fr /var/lib/apt/lists/* \
    && wget -qO- \
	    https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm | \
	    perl - --skip-satisfied App::cpanminus \
    && rm -r ~/.cpanm \
    && cpanm \
		Math::Random \
		Statistics::Distributions \
		Archive::Zip \
		File::Copy::Recursive \
		Storable \
		Moose \
		MooseX::Params::Validate \
		Test::Exception \
		YAML::Tiny

WORKDIR /tmp

# install PsN
RUN curl -SL https://github.com/UUPharmacometrics/PsN/releases/download/4.7.0/PsN-4.7.0.tar.gz -o PsN-4.7.0.tar.gz \
    && tar -zxf /tmp/PsN-4.7.0.tar.gz \
    && cd /tmp/PsN-Source \
    && expect -c "set timeout { 2 exit }; \
        spawn perl setup.pl; \
		expect -ex \"PsN Utilities installation directory \[/usr/local/bin\]:\"; \
		send \"\r\"; \
		expect -ex \"Path to perl binary used to run Utilities \[/usr/bin/perl\]:\"; \
		send \"\r\"; \
		expect -ex \"PsN Core and Toolkit installation directory \[/usr/local/share/perl\"; \
		send \"\r\"; \
		expect -ex \"Would you like this script to check Perl modules \[y/n\]?\"; \
		send \"y\r\"; \
		expect -ex \"Continue installing PsN (installing is possible even if modules are missing)\[y/n\]?\"; \
		send \"y\r\"; \
		expect -ex \"Would you like to copy the PsN documentation to a file system location of your choice?\"; \
		send \"n\r\"; \
		expect -ex \"Would you like to install the PsN test library?\"; \
		send \"y\r\"; \
		expect -ex \"PsN test library installation directory \[/usr/local/share/perl/\"; \
		send \"\r\"; \
		expect -ex \"Would you like help to create a configuration file?\"; \
		send \"y\r\"; \
        expect -ex \"Enter the *complete* path of the NM-installation directory:\"; \
        send \"/opt/nm/\r\"; \
		expect -ex \"Would you like to add another one\"; \
		send \"n\r\"; \
		expect -ex \"or press ENTER to use the name\"; \
		send \"nm\r\"; \
		expect -ex \"installation program.\"; \
		send \"\r\";" \
    && rm -rf /tmp/*

# default number of nonmem threads, based on your nonmem license
# this is written to a /root/psn.conf on startup using the docker-entrypoint.sh
# no need to change it here, you can change it in docker-compose.yml or at command line with -e
ENV NUM_THREADS=4

ENV OMPI_VERSION=4.1.2
ENV OMPI_MAJOR_VERSION=4.1
ENV OMPI_SHA256=a400719b04375cd704d2ed063a50e42d268497a3dfede342986ab7a8d7e8dcf0

ENV DOMINO_USER=ubuntu
ENV DOMINO_GROUP=ubuntu

# Create ubuntu user
RUN if ! id 12574 &> /dev/null; then \
        groupadd -g 12574 ${DOMINO_GROUP}; \
        useradd -u 12574 -g 12574 -m -N -s /bin/bash ${DOMINO_USER}; \
    fi

WORKDIR /opt

#NOTE:build essentials is already present in most Domino distributions.

RUN apt-get -y update && apt-get -y install curl libdigest-sha-perl build-essential

# see https://www.open-mpi.org/faq/?category=running#mpirun-prefix to find config options.
# https://www.open-mpi.org/faq/?category=building#where-to-install
RUN curl -o openmpi-${OMPI_VERSION}.tar.gz https://download.open-mpi.org/release/open-mpi/v${OMPI_MAJOR_VERSION}/openmpi-${OMPI_VERSION}.tar.gz && \
    echo "${OMPI_SHA256}  openmpi-${OMPI_VERSION}.tar.gz" | shasum -a 256 -c && \
    tar -xf openmpi-${OMPI_VERSION}.tar.gz && \
    cd openmpi-${OMPI_VERSION} && \
    ./configure \
        --prefix=/opt/mpi \
        --enable-mpirun-prefix-by-default && \
    make -j $(nproc) all && \
    make install

# set the PATH vars appropriately using domino-defaults
# https://www.open-mpi.org/faq/?category=running#run-prereqs
RUN \
    echo "export PATH=/opt/mpi/bin:\$PATH" >> /home/${DOMINO_USER}/.domino-defaults && \
    if [ -z "$LD_LIBRARY_PATH" ]; then \
        echo "export LD_LIBRARY_PATH=/opt/mpi/lib" >> /home/${DOMINO_USER}/.domino-defaults; \
    else \
        echo "export LD_LIBRARY_PATH=/opt/mpi/lib:\$LD_LIBRARY_PATH" >> /home/${DOMINO_USER}/.domino-defaults; \
    fi && \
    echo "export OMPI_VERSION=$OMPI_VERSION" >> /home/${DOMINO_USER}/.domino-defaults

WORKDIR /

USER ubuntu

# Install Terminal
USER root
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

# Install ttyd
RUN curl -sL "https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64" -o /usr/local/bin/ttyd
RUN chmod +x /usr/local/bin/ttyd

RUN mkdir -p /var/opt/workspaces/ttyd/

RUN cat > /var/opt/workspaces/ttyd/start <<EOF

#!/bin/bash
set -o nounset -o errexit -o pipefail

# Run ttyd on port 8888 with command bash
ttyd -p 8888 bash

EOF

RUN chmod +x /var/opt/workspaces/ttyd/start

USER ubuntu