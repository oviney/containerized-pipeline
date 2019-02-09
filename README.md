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
