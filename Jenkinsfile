pipeline {  

    environment {
        IMAGE_NAME = "static-website"
        IMAGE_TAG = "v-1.0"
        CONTAINER_NAME = "static-website"
        USERNAME = "clev42"
        EC2_STAGING_HOST = "18.212.32.135"
        EC2_PROD_HOST = "18.208.170.171"
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
    
       stage ('Run test container') {
           agent any
           steps {
               script{
                   sh '''
                       docker stop $CONTAINER_NAME || true
                       docker rm $CONTAINER_NAME || true
                       docker run --name $CONTAINER_NAME -d -p 5000:80 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                       sleep 5
                   '''
               }
           }
       }

       stage ('Test container') {
           agent any
           steps {
               script{
                   sh '''
                       curl -s http://localhost:5000 | grep -iq dimension
                   '''
               }
           }
       }

       stage ('clean env and save artifact') {
           agent any
           environment{
               PASSWORD = credentials('dockerhub_password')
           }
           steps {
               script{
                   sh '''
                       docker login -u $USERNAME -p $PASSWORD
                       docker push $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                       docker stop $CONTAINER_NAME || true
                       docker rm $CONTAINER_NAME || true
                       docker rmi $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                   '''
               }
           }
       }
        
        stage('STAGING Deploy app on EC2') {
            agent any
            when{
                expression{ GIT_BRANCH == 'origin/master'}
            }
            steps{
            withCredentials([sshUserPrivateKey(credentialsId: "ec2-deploy-web", keyFileVariable: 'keyfile', usernameVariable: 'NUSER')]) {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script{
                        sh'''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${EC2_STAGING_HOST} docker rm --force $CONTAINER_NAME || true
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${EC2_STAGING_HOST} docker run --name $CONTAINER_NAME -d -p 5001:80 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        '''
                    }
                }
            }
            }
        }
        stage('PROD Deploy app on EC2') {
            agent any
            when{
                expression{ GIT_BRANCH == 'origin/master'}
            }
            steps{
            withCredentials([sshUserPrivateKey(credentialsId: "ec2-deploy-web", keyFileVariable: 'keyfile', usernameVariable: 'NUSER')]) {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    script{
                        sh'''
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${EC2_PROD_HOST} docker rm --force $CONTAINER_NAME || true
                            ssh -o StrictHostKeyChecking=no -i ${keyfile} ${NUSER}@${EC2_PROD_HOST} docker run --name $CONTAINER_NAME -d -p 5001:80 $USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        '''
                    }
                }
            }
            }
        }
    }
}
