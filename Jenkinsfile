pipeline {
    agent any

    stages {
        stage('Check repository') {
            steps {
                sh '''
                    echo "Current directory:"
                    pwd

                    echo "Repository files:"
                    ls -la

                    echo "Scripts:"
                    ls -la scripts

                    echo "Test plans:"
                    ls -la test-plans
                '''
            }
        }
    }
}