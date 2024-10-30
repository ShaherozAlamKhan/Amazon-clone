# E-Commerce Platform Development: Creating an Amazon Clone with CI/CD Pipeline and Automated Deployment Using Jenkins and GitHub Integration

## Aim

The aim of this project is to develop an Amazon clone e-commerce website and integrate it into a Continuous Integration and Continuous Deployment (CI/CD) pipeline using Jenkins. The CI/CD pipeline will automate code building, testing, and deployment, enabling seamless and rapid updates. The final application will be hosted on an AWS EC2 instance using an NGINX server. Through this project, we aim to showcase how DevOps practices streamline web development and deployment workflows, ensuring efficient, reliable, and consistent application delivery with minimal manual intervention.

## Prerequisites

1. **AWS Account**: Set up with IAM roles and EC2.
2. **Basic Knowledge of Web Development**: HTML, CSS, JavaScript, Node.js (or another backend), and basic front-end design for an e-commerce site.
3. **GitHub Account**: To host the project repository.
4. **Jenkins Server**: Deployed on an EC2 instance with internet access and plugins for GitHub integration.
5. **CI/CD Concepts**: Basic understanding of Continuous Integration and Continuous Deployment.

## Objectives

1. Develop an Amazon Clone e-commerce website.
2. Implement a CI/CD pipeline using Jenkins to automate the build, test, and deployment processes.
3. Host the website on AWS and configure automatic updates through Jenkins on code changes in GitHub.

## Architecture

   ![jenkins](https://github.com/user-attachments/assets/7e6bfe05-b035-495b-91ad-8b731822be0b)


## Steps

### 1. Configuring AWS Resources

- **EC2 Instance**: Launch an instance to serve as the web server for the application.
- **Security Groups**: Configure Security Groups to allow traffic to the web server.
  - Enable:
    - HTTP
    - HTTPS 
    - Custom TCP (8080, Anywhere) 
    - Custom TCP (8000, Anywhere)
    - SSH (for Remote Access)

### 2. Setting Up Jenkins and Necessary Software on EC2

Access the EC2 instance and run the following commands to install necessary packages and Jenkins:

```bash
# Update the package list
sudo apt update

# Install OpenJDK 17
sudo apt install openjdk-17-jdk -y

# Verify the Java installation
java -version

# Add the Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to the sources list
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update the package list
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y

# Enable Jenkins to start on boot and start the service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install and start Nginx
sudo apt install nginx -y
sudo service nginx start

# Enable Nginx to start on boot
sudo systemctl enable nginx
```
### 3. Access Jenkins
- Copy the Public IP Address of the EC2 instance and paste it into a browser followed by `:8080`.
- Use the initial admin password located in `/var/lib/jenkins/secrets/initialAdminPassword`.
- Install the suggested plugins and create an admin user.

### 4. Create GitHub Personal Access Token
- Go to GitHub Profile → Settings → Developer Settings → Personal Access Tokens (classic).
- Generate a new token and copy it.

### 5. Connect Jenkins to GitHub
In Jenkins:
- Navigate to `Manage Jenkins → Configure System`.
- Scroll down to GitHub Server:
  - **Name**: GitHub
  - **API URL**: `https://api.github.com`
  - **Credentials**: Add the Personal Access Token.
    - **Kind**: Secret Text
    - **Secret**: Paste the personal access token.
    - **ID**: Jenkins
- Test the connection to see your GitHub username.

### 6. Creating a Jenkins Job
In Jenkins, create a new item:
- **Item Name**: `shaheroz`
- **Type**: Freestyle Project
- Under General:
  - Enable GitHub Project and provide the repository URL.
- Under Source Code Management:
  - **Repository URL**: `https://github.com/ShaherozAlamKhan/Amazon-clone`
  - **Branch Specifier**: `*/main`
- Under Build Steps:
  - Add a build step **Execute Shell** and enter the following commands:

    ```bash
    sudo docker ps --filter "publish=8000" -q | xargs -r docker rm -f
    sudo docker build . -t shaheroz
    sudo docker run -p 8000:80 -d shaheroz
    ```

- Save and click **Build Now**.
- After a successful build, access the web app via the public IP of EC2 followed by `:8080`.

### 7. Configuring Docker Permissions for Jenkins
Before clicking **Build Now**, go to EC2 and add the following line to the sudoers file to allow Jenkins to run Docker without a password:

```bash
jenkins ALL=(ALL) NOPASSWD: /usr/bin/docker
```
### 8. Automating Deployment Using SSH Keys and Webhooks
Generate SSH keys on the Jenkins server:

```bash
# Generate SSH keys
ssh-keygen

# Navigate to the .ssh directory
cd ~/.ssh

# List all files to confirm SSH keys are generated
ls -al

# View public SSH key (this will be copied to the target EC2 instance)
cat ~/.ssh/id_ed25519.pub

# View private SSH key (use cautiously and only for verification purposes)
cat ~/.ssh/id_ed25519
```
### Adding the SSH Key to GitHub
Copy the public SSH key and add it to GitHub:

1. Go to `Settings → SSH and GPG Keys → New SSH Key`.
   - **Title**: Jenkins Public SSH Key.
   - **Key Type**: Authentication Key.
   - **Key**: Paste the public key.

### Adding the Private SSH Key to Jenkins
Add the private SSH key to Jenkins:

1. Go to `Manage Jenkins → Configure System → GitHub Server`:
   - **Kind**: SSH Username and Private Key.
   - **Private Key**: Enter the private SSH key manually.

### 9. Setting Up GitHub Webhooks
In GitHub:

1. Go to `Repository Settings → Webhooks → Add Webhook`.
   - **Payload URL**: `http://<EC2_Public_IP>:8080/github-webhook/`
   - **Content Type**: `application/json`.
2. Add the webhook.

In Jenkins:

1. Go to the `shaheroz` job.
2. Under Build Triggers, enable `GitHub hook trigger for GITScm polling`.

### 10. Grant Docker Permissions to Jenkins
Run the following commands to grant Jenkins permission to run Docker:
```bash
# Add Jenkins user to the Docker group
sudo usermod -aG docker jenkins

# Restart Jenkins and Docker
sudo systemctl restart jenkins
sudo systemctl restart docker

# Verify group membership for Jenkins
sudo su - jenkins
groups  # Should see "jenkins docker"
exit
```
### 11. Testing Automatic Builds
Update a file in the GitHub repository (such as `index.html`) and commit the changes. This will initiate the build process through a webhook in Jenkins, ensuring that the updates are reflected in real-time on the EC2 instance.


