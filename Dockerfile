FROM jenkins/jenkins:lts

LABEL maintainer="Ouray Viney"

# Get rid of admin password setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# If we want to install via apt
USER root

# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk maven && \
    # apt-get install -y python python-pip && \ 
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Install Python modules
# RUN pip install python-jenkins

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Auto install Jenkins plugins
COPY jenkins-plugins.txt /usr/share/jenkins/ref/jenkins-plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/jenkins-plugins.txt

# Auto setup of Java and Maven tools
COPY groovy/install_java.groovy /var/jenkins_home/init.groovy.d/
COPY groovy/install_maven.groovy /var/jenkins_home/init.groovy.d/

# COPY jenkins-plugins.txt /tmp
# COPY jenkins-utils.py /tmp
# COPY __init__.py /usr/local/lib/python2.7/dist-packages/jenkins
# RUN cd /tmp && \
#     python jenkins-utils.py;