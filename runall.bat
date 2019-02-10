set jenkins_port=8080
set sonar_port=9001
set ip_address=127.0.0.1

echo "Grab the latest LTS"
REM docker pull jenkins/jenkins:lts

echo "Pull SonarQube latest"
REM docker pull sonarqube:latest
echo "Stop any existing Docker containers before starting"
REM docker stop mysonar myjenkins
docker stop myjenkins
echo "Build Custom Docker container based on latest Jenkins LTS"
docker build --no-cache -t myjenkins .
echo "Start Docker SonarQube container"
echo "docker run -p %sonar_port%:9000 --rm --name mysonar sonarqube:latest"
echo "Start Custom Docker Jenkins container, Jenkin plugin auto install, admin password disabled, Java 8, Maven"
REM docker run -p %jenkins_port%:8080 --rm --name myjenkins -e SONARQUBE_HOST=http://%ip_address%:%sonar_port% myjenkins:latest
docker run -itd -p %jenkins_port%:8080 --rm --name myjenkins myjenkins:latest
REM echo "Install Jenkins Plugins"
REM python jenkins-utils.py