pipeline {
    agent any
    
    stages {
        stage('Checkout SVN') {
            steps {
                dir('temp') {
                    svn 'https://example.com/svn/repo'
                }
            }
        }
        
        stage('Clone Git') {
            steps {
                git 'https://github.com/user/repo.git'
                sh 'mkdir temp/git-code'
                sh 'cp -r * temp/git-code/'
            }
        }
        
        stage('Build and Test') {
            steps {
                dir('temp') {
                    sh 'make install'
                    sh 'make test'
                }
            }
        }
        
        stage('Push to Git') {
            steps {
                git 'https://github.com/user/repo.git'
                sh 'cp -r temp/git-code/* .'
                gitPush(branch: 'main', credentialsId: 'git-credentials', message: 'Build succeeded')
            }
        }
    }
    
    post {
        always {
            deleteDir()
        }
        success {
            emailext (
                to: 'usuario@ejemplo.com',
                subject: 'Build succeeded',
                body: 'The build succeeded.'
            )
        }
        failure {
            emailext (
                to: 'usuario@ejemplo.com',
                subject: 'Build failed',
                body: 'The build failed.'
            )
        }
    }
}
