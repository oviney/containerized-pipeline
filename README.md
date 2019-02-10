# Dockerizing Jenkins - Declarative Build Pipeline With SonarQube Analysis
Dockerizing Jenkins, learn to run Jenkins on Docker, and automate plugin installation, Java and Maven tool configuration, and more.

# Scope of Tutorial
In this tutorial, I am going to demonstrate:

* Running Jenkins on Docker
* Automation of Jenkins plugin installation on Docker
* Configuring Java and Maven tools on Jenkins, first manually and then via the Groovy scripts
* Automating the above step with Docker
* Running SonarQube on Docker
* Setting up a Java Maven pipeline with unit tests, test coverage, and SonarQube analysis steps

# Let's get started
This will be a hands on tutorial, so be ready to get your hands dirty.  By the end, you should be able to run the pipeline on a fully automated Jenkins Docker container.

As you may already know, with Jenkins 2, you can actually have your build pipeline right within your Java project, so you can actually use your own Maven Java project in order to follow the steps in this article as long as it is hosted on a Git repository.

Everything obviously will be running on Docker, as it is the easiest way of deploying and running them.

So, let’s see how to run Jenkins on Docker:

> Grab the latest LTS

`docker pull jenkins/jenkins:lts`

While it is downloading in the background, let’s review what we are going to do with the Docker Jenkins container once it is done.

Default Jenkins comes quite bare.  So we'll demonstrate how we can automate plugin installation in the Docker image we are going to build and will follow this simple rule (automate everything) throughout all the steps:

* Set up manually
* Set up programmatically
* Automate with Docker

The Docker Jenkins image we are downloading is ~700MB. I will take you through the additional steps to setup up build a pipeline for a Java project. Let’s add them to the list and look closer later:

* Pull the code from SCM
* Configuration of Java and Maven
* Running unit tests
* Running static analysis
* Sending report to SonarQube for further processing
* And finally, deployment of the .jar file to the repository (e.g. Nexus repo.  Will be covered in the next tutorial)
* Optional: release it after each commit

> Once you have your image downloaded, let’s run the container:

`docker run -p 8080:8080 --rm --name myjenkins jenkins/jenkins:lts`

> I used a specific tag; I am using the latest LTS tag, I want the version to always be the latest LTS version.

> We name the container `--name myjenkins`  so it is easier to refer to it later, otherwise, Docker will name it randomly, and we added the `–-rm` flag to delete the container once we stop it.  This will ensure we are running Jenkins in an immutable fashion and everything configures on the fly.  If we want to preserve any data, we will do it explicitly.

We won't need to worry about setting an admin password.  This was automated in the Docker file.

> Get rid of admin password setup

`ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"`

That said, we only use the trick once we have installed the recommended Jenkins plugins.  You do this the first time manually by navigating to http://127.0.0.1.  We can you use Python to extract the default list of plugins.  In the Python script I import a Jenkins module (python-jenkins) that lets you send Groovy scripts via HTTP using the requests libray.  I decided to take this approach when I discovered that Jenkins doesn't have a REST interface for these types of tasks.  I didn't want to use curl or wget as Windows doesn't typically have those tools available.  The Python script sends a request to your Jenkins container, gets a list of the installed Jenkins plugins and writes it to disk.  Then, sends a request to your Jenkins container, installing all the desired plugins.  Since I have done that already, you won't need to use the Python script.  

> Let’s stop the container and automate this step:

`docker stop myjenkins`

> Let’s start Dockerizing the Jenkins plugin, Java installation part now by creating an empty file called Dockerfile and adding couple lines to it:

```FROM jenkins/jenkins:lts

LABEL maintainer="Ouray Viney"

# Get rid of admin password setup
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# If we want to install via apt
USER root

# COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
# RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y python && \ 
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Auto install Jenkins plugins
COPY jenkins-plugins.txt /usr/share/jenkins/ref/jenkins-plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/jenkins-plugins.txt
```

> Time to build our image:

```docker build -t myjenkins .```

> The dot `.` in the end, don’t miss it.  It will take a while as now the Docker Jenkins image has been instructed to download and install the plugins we defined in jenkins-plugins.txt (use the `jenkins-utils.py`). Once it is ready, we can run it:

```docker run -p 8080:8080 --rm --name myjenkins myjenkins:latest```

> This time we are not running the container from the default image, but the one we have just built. You can check installed plugins by running the same script I did (`jenkins-utils.py`):

```Python
import json

import jenkins
import requests
import time

# pip install python-jenkins

# server = jenkins.Jenkins('<jenkinsurl>', username='<Jenkins_user>', password='<Jenkins_User_password>')
server = jenkins.Jenkins('http://localhost:8080')

# iterate over list of installed Jenkins plugins
def get_plugins_info(server_object):

    # read in jenkins plugins to be installed
    with open('jenkins-plugins.txt', 'r') as f:
        read_data = f.read().splitlines()
    f.closed
    print("Total number of desired Jenkins plugins: {0}".format(len(read_data)))
    return read_data

def install_jenkins_plugins(server_object, jenkins_plugins_to_install):
    try:
        print("About to install the following Jenkins plugins: '{0}'").format(jenkins_plugins_to_install)
        for plugin in jenkins_plugins_to_install:
            server.install_plugin(plugin)
        
    except IndexError:
        print("Error occurred, you'll need to debug the code.")

def list_jenkins_plugins(server_object):
    # get jenkins plugin list
    all_plugins_info=server.get_plugins_info()
    # print("All plugins: {0}".format(all_plugins_info))

    jenkins_plugins_shortname = []
    for each_plugin in all_plugins_info:
        jenkins_plugins_shortname.append(each_plugin['shortName'].encode("utf-8")) # avoid a list with u' character
    print("Total number of installed Jenkins plugins in local running container: {0}".format(len(jenkins_plugins_shortname)))
    return jenkins_plugins_shortname

def restart_jenkins(server):
    url = "http://localhost:8080/restart"
    try:
        response = jenkins.Jenkins.jenkins_open(server, requests.Request('POST', url)).encode("UTF-8")
        return response
    except:
        print ("Jenkins server restarting, please wait a few minutes.")

print("Sleeping for 1 min to wait for Jenkins to start up for the first time.")
time.sleep(60)
# Get the list of Jenkins plugins to install
jenkins_plugins = get_plugins_info(server)
# Install plugins
install_jenkins_plugins(server, jenkins_plugins)
# Restart Jenkins server, required when installing plugins
restart_jenkins(server)
# Force a 30 second sleep to let Jenkins restart gracefully
print("Sleeping for 1 min to wait for Jenkins to restart.")
time.sleep(60)
# List plugins installed in local Jenkins Docker container
print("Plugins installed in local Jenkins Docker container: {0}".format(list_jenkins_plugins(server)))
```

To just get the installe plugins you can run it like this:

```Python

# List plugins installed in local Jenkins Docker container
print("Plugins installed in local Jenkins Docker container: {0}".format(list_jenkins_plugins(server)))
```

The output will be something like this:

```Python

[Running] python -u "c:\Users\Ouray.Viney\docker-dev-work\jenkins-docker-pipeline-tutorial\jenkins-utils.py"
Total number of installed Jenkins plugins in local running container: 74
Plugins installed in local Jenkins Docker container: ['cloudbees-folder', 'plain-credentials', 'jsch', 'subversion', 'docker-workflow', 'pipeline-stage-view', 'pipeline-model-declarative-agent', 'git-client', 'workflow-aggregator', 'script-security', 'pipeline-model-extensions', 'bouncycastle-api', 'build-timeout', 'ant', 'branch-api', 'structs', 'durable-task', 'pipeline-graph-analysis', 'workflow-cps-global-lib', 'authentication-tokens', 'github', 'momentjs', 'apache-httpcomponents-client-4-api', 'pipeline-build-step', 'github-branch-source', 'scm-api', 'credentials-binding', 'pipeline-stage-tags-metadata', 'jackson2-api', 'cobertura', 'junit', 'pipeline-input-step', 'gradle', 'antisamy-markup-formatter', 'workflow-basic-steps', 'pipeline-rest-api', 'pipeline-github-lib', 'pam-auth', 'github-api', 'display-url-api', 'ace-editor', 'credentials', 'workflow-multibranch', 'timestamper', 'pipeline-stage-step', 'docker-commons', 'mapdb-api', 'workflow-step-api', 'resource-disposer', 'git-server', 'ssh-slaves', 'workflow-scm-step', 'ldap', 'handlebars', 'workflow-api', 'ssh-credentials', 'email-ext', 'workflow-job', 'pipeline-model-api', 'ws-cleanup', 'pipeline-milestone-step', 'jquery-detached', 'windows-slaves', 'pipeline-model-definition', 'git', 'matrix-auth', 'lockable-resources', 'token-macro', 'workflow-support', 'mailer', 'workflow-cps', 'matrix-project', 'code-coverage-api', 'workflow-durable-task-step']

[Done] exited with code=0 in 0.906 seconds
```

# Tool Installation
We have already installed Java and Apache Maven, so that is covered.  That is done in the Docker file, here is the code:

```Docker
# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk maven && \
    apt-get clean;
```
