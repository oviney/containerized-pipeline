import hudson.tasks.Maven
import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor
import hudson.tools.ZipExtractionInstaller;
import hudson.util.DescribableList
import jenkins.model.Jenkins;

a=Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
b=(a.installations as List);
println("Setting up tool:  maven3")
b.add(new hudson.tasks.Maven.MavenInstallation("maven3", "/usr/share/maven/", []));
a.installations=b
a.save()