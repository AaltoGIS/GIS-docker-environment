FROM jupyter/scipy-notebook

MAINTAINER Johannes Nyman <johannes.nyman@csc.fi>

WORKDIR /opt/app
USER 1000

### Installing the GIS libraries and jupyter lab extensions. Modify this and make sure the conda spell is working
RUN echo "Upgrading conda" \
&& conda update --yes -n base conda

# Install environment from local yml file
COPY environment.yml .
RUN conda env update -n base -f environment.yml

# Install packages from requirements with pip (conda pip installation has issues with docker)
# There might be a solution, check later.
# See issue: https://github.com/jupyter/docker-stacks/issues/678

# NOTE: If you do not have any packages to install with pip comment out following two lines
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN jupyter lab build

RUN conda clean -afy

USER root

# OpenShift allocates the UID for the process, but GID is 0
# Based on an example by Graham Dumpleton
RUN chgrp -R root /home/jovyan \
    && find /home/jovyan -type d -exec chmod g+rwx,o+rx {} \; \
    && find /home/jovyan -type f -exec chmod g+rw {} \; \
    && chgrp -R root /opt/conda \
    && find /opt/conda -type d -exec chmod g+rwx,o+rx {} \; \
    && find /opt/conda -type f -exec chmod g+rw {} \;

# IS this needed?
#RUN ln -s /usr/bin/env /bin/env

ENV HOME /home/jovyan

COPY ./instance_start_script.sh /usr/local/bin/instance_start_script.sh
RUN chmod a+x /usr/local/bin/instance_start_script.sh

# compatibility with old blueprints, remove when not needed
#RUN ln -s /usr/local/bin/instance_start_script.sh /usr/local/bin/bootstrap_and_start.bash

USER 1000

WORKDIR /home/jovyan/work

CMD ["/usr/local/bin/instance_start_script.sh"]

