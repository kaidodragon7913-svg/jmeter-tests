pipeline {
    agent any

    parameters {
        string(name: 'THREADS', defaultValue: '10')
        string(name: 'RAMPUP', defaultValue: '30')
        string(name: 'DURATION', defaultValue: '300')
        string(name: 'URL', defaultValue: 'http://localhost')
        string(name: 'THROUGHPUT', defaultValue: '100')
        string(name: 'TEST_PLAN', defaultValue: 'load_test.jmx')
    }

    environment {
        SSH_HOST = 'root@172.17.0.1'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run JMeter via SSH') {
            steps {

                sshagent(credentials: ['host-ssh-key']) {

                    sh '''
                        ssh -o StrictHostKeyChecking=no ${SSH_HOST} "

                            mkdir -p /opt/jmeter-run

                            rm -rf /opt/jmeter-run/*

                        "
                    '''

                    sh '''
                        scp -o StrictHostKeyChecking=no -r \
                          test-plans \
                          data \
                          properties \
                          scripts \
                          ${SSH_HOST}:/opt/jmeter-run/
                    '''

                    sh '''
                        ssh -o StrictHostKeyChecking=no ${SSH_HOST} "

                            cd /opt/jmeter-run

                            chmod +x scripts/run_jmeter.sh

                            ./scripts/run_jmeter.sh \
                              ${TEST_PLAN} \
                              ${THREADS} \
                              ${RAMPUP} \
                              ${DURATION} \
                              ${URL} \
                              ${THROUGHPUT}

                        "
                    '''
                }
            }
        }

        stage('Download results') {
            steps {

                sshagent(credentials: ['host-ssh-key']) {

                    sh '''
                        mkdir -p results

                        scp -o StrictHostKeyChecking=no -r \
                          ${SSH_HOST}:/opt/jmeter-run/results/* \
                          results/ || true
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results/**/*', allowEmptyArchive: true
        }
    }
}