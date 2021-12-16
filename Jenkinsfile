pipeline {

    environment {
        IMAGE_NAME = "static-website"
        IMAGE_TAG = "alpha-0.1"
        CONTAINER_NAME = "static-website"
        USERNAME = "clev42"
    }

    agent none

    stages{

       stage ('Build Image'){
           agent any
           steps {
               script{
                   sh 'docker build -t $USERNAME/$IMAGE_NAME:$IMAGE_TAG .'
               }
           }
       }
    }
}
