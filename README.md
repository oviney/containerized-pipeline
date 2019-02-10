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

**Note:** I used a specific tag; I am using the latest LTS tag, I want the version to always be the latest LTS version.

**Note:** We name the container `--name myjenkins`  so it is easier to refer to it later, otherwise, Docker will name it randomly, and we added the `–-rm` flag to delete the container once we stop it.  This will ensure we are running Jenkins in an immutable fashion and everything configures on the fly.  If we want to preserve any data, we will do it explicitly.

We won't need to worry about setting an admin password.  This was automated in the Docker file.

> Get rid of admin password setup

`ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"`

That said, we only use the trick once we have installed the recommended Jenkins plugins.  You do this the first time manually by navigating to http://127.0.0.1.  We extract the default list of plugins using a Pythong script.  In the Python script I use a Jenkins module that lets you send Groovy scripts via HTTP using the requests libray.  I decide to take this approach when I discovered that Jenkins doesn't have a REST interface for this types of tasks.  The Python script sends a request to your Jenkins container, gets a list of the installed Jenkins plugins and writes it to disk.  Then, sends a request to your Jenkins container, installing all the desired plugins.

> Let’s stop the container and automate this step:

`docker stop myjenkins`


