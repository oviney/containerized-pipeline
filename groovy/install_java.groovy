import hudson.model.JDK
import hudson.tools.InstallSourceProperty

def descriptor = new JDK.DescriptorImpl();

def List<JDK> installations = []

javaTools = [['name':'jdk8', 'url':'/usr/lib/jvm/java-8-openjdk-amd64/']]

javaTools.each { javaTool ->
	println("Setting up tool: ${javaTool.name}")
	def jdk = new JDK(javaTool.name as String, javaTool.url as String)
	installations.add(jdk)
}
descriptor.setInstallations(installations.toArray(new JDK[installations.size()]));
descriptor.save()