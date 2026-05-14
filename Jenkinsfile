pipeline {
    agent any

    parameters {
        string(name: 'THREADS', defaultValue: '10')
        string(name: 'RAMPUP', defaultValue: '30')
        string(name: 'DURATION', defaultValue: '300')
        string(name: 'URL', defaultValue: '5.42.97.48')
        string(name: 'THROUGHPUT', defaultValue: '100')
        string(name: 'TEST_PLAN', defaultValue: 'test_pipe.jmx')
    }

    environment {
        SSH_HOST = 'root@172.17.0.1'
        REMOTE_DIR = "/opt/jmeter-runs/build-${BUILD_NUMBER}"
    }

    stages {
        stage('Prepare remote dir') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            mkdir -p ${REMOTE_DIR}
                            rm -rf ${REMOTE_DIR}/*
                        "
                    '''
                }
            }
        }

        stage('Upload project to host') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -r \
                          test-plans \
                          data \
                          properties \
                          scripts \
                          ${SSH_HOST}:${REMOTE_DIR}/
                    '''
                }
            }
        }

        stage('Run JMeter on host') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            cd ${REMOTE_DIR}
                            chmod +x scripts/run_jmeter.sh

                            ./scripts/run_jmeter.sh \
                              ${TEST_PLAN} \
                              ${THREADS} \
                              ${RAMPUP} \
                              ${DURATION} \
                              ${URL} \
                              ${THROUGHPUT} &

                            REMOTE_PID=\$!
                            echo \$REMOTE_PID > jmeter.pid

                            cleanup() {
                              if kill -0 \$REMOTE_PID 2>/dev/null; then
                                kill -TERM \$REMOTE_PID 2>/dev/null || true
                                wait \$REMOTE_PID 2>/dev/null || true
                              fi
                            }

                            trap cleanup TERM INT HUP

                            wait \$REMOTE_PID
                            EXIT_CODE=\$?
                            rm -f jmeter.pid
                            exit \$EXIT_CODE
                        "
                    '''
                }
            }
        }

        stage('Download results') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        mkdir -p results

                        scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -r \
                          ${SSH_HOST}:${REMOTE_DIR}/results/* \
                          results/ || true
                    '''
                }
            }
        }
    }

    post {
        aborted {
            withCredentials([
                sshUserPrivateKey(
                    credentialsId: 'host-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    usernameVariable: 'SSH_USER'
                )
            ]) {
                sh '''
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                        if [ -f ${REMOTE_DIR}/jmeter.pid ]; then
                            PID=\\$(cat ${REMOTE_DIR}/jmeter.pid)
                            kill -TERM \\${PID} 2>/dev/null || true
                            wait \\${PID} 2>/dev/null || true
                            rm -f ${REMOTE_DIR}/jmeter.pid
                        fi
                    " || true
                '''
            }
        }
        always {
            archiveArtifacts artifacts: 'results/**/*', allowEmptyArchive: true
        }
    }
}
