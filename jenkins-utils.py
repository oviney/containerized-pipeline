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

# print("Sleeping for 1 min to wait for Jenkins to start up for the first time.")
# time.sleep(60)
# Get the list of Jenkins plugins to install
# jenkins_plugins = get_plugins_info(server)
# Install plugins
# install_jenkins_plugins(server, jenkins_plugins)
# Restart Jenkins server, required when installing plugins
# restart_jenkins(server)
# Force a 30 second sleep to let Jenkins restart gracefully
# print("Sleeping for 1 min to wait for Jenkins to restart.")
# time.sleep(60)
# List plugins installed in local Jenkins Docker container
print("Plugins installed in local Jenkins Docker container: {0}".format(list_jenkins_plugins(server)))
