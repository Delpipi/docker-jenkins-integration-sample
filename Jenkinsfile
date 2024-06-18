def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger',
]

pipeline {
	agent any
	tools {
	   maven "Maven3"
	   jdk "Openjdk17"
	}

	stages {

	   	stage('Build') {
	      	steps {
	         	sh 'mvn install -DskipTests'
	      	}

	      	post {
		     	success {
		       		echo 'Archiving artifacts now.'
		       		archiveArtifacts artifacts: '**/*.jar'
		     	}
	   		}
	   	}

	   	stage('UNIT TEST') {
	      steps {
	        sh 'mvn test'
	      }
	   	}

	   	stage('Checkstyle Analysis') {
	   		steps {
	   			sh 'mvn checkstyle:checkstyle'
	   		}
	   	}

	   	stage('Sonar Analysis') {
	   		environment {
	   			scannerHome = tool 'sonar6.0'
	   		}

	   		steps {
	   			withSonarQubeEnv('sonar') {
	   				sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=docker-jenkins-integration-sample \
                   -Dsonar.projectName=docker-jenkins-integration-sample \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/main/java \
                   -Dsonar.tests=src/test/java \
                   -Dsonar.java.binaries=target/classes \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
	   			}
	   		}
	   	}

	   	stage('UploadArtifact') {
	   		steps {
	   			nexusArtifactUploader(
					nexusVersion: 'nexus3',
					protocol: 'http',
					nexusUrl: '127.0.0.1:8081',
					groupId: 'QA',
					version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
					repository: 'docker-jenkins-integration-sample-repo',
					credentialsId: 'nexuslogin',
		                artifacts: [
		                    [artifactId: 'docker-jenkins-integration-sample',
		                     classifier: '',
		                     file: 'target/docker-jenkins-integration-sample.jar',
		                     type: 'jar']
						]
				)
	   		}
	   	}
	}

	post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#jenkinscicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
}