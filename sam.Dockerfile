FROM python:3.11

RUN apt-get update && \
    apt-get -y upgrade

RUN mkdir /sam/

ADD sam-requirements.txt sam-requirements.txt

RUN pip install -r sam-requirements.txt

WORKDIR /sam/


#what the dockerfile does:
#FROM python:3.11: uses the official Python 3.11 image as the base image
#RUN apt-get update && apt-get -y upgrade: updates the package lists and upgrades the installed packages to their latest versions
#RUN mkdir /sam/: creates a directory called /sam/ in the container
#ADD sam-requirements.txt sam-requirements.txt: adds the sam-requirements.txt file from the host machine to the container
#RUN pip install -r sam-requirements.txt: installs the Python packages listed in the sam-requirements.txt file