![](images/easytrain-packer.png)

# EasyTrain-Packer

This Packer template builds an Amazon Machine Image (AMI) that is used to
create an EC2 instance in the [easytrain-terraform](https://github.com/EasyTrain/easytrain-terraform) project for the [easytrain/application](https://github.com/EasyTrain/application).

The EasyTrain application is deployed on AWS at [easytrain.live](https://easytrain.live/)

## Description

Packer uses the Ubuntu Server 24.04 LTS AMI in the eu-central-1 region as the base image. The following are then installed and configured:

- Install install openjdk-21-jdk
- Install the latest version of PostgreSQL
- Create tables required by the application, user login and user session
- Enable Postgres to run as a Systemd service on system startup
- Insert station data into the Postgres tables
- Copy the application source files to the `/app` directory
- Package the application with Maven
- Enable the appplication to run as a Systemd service on startup

## Dependencies

Packer version 1.2.8 or higher  
AWS Account  
AWS CLI 1.15.58  
A valid AWS Access Key ID and Secret Access Key configured with the AWS CLI  
An Ubuntu base AMI for your specific region