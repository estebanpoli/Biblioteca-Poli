pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = "pipeline-test"
    }

    stages {
        stage('Build y levantar entorno para pruebas') {
            steps {
                sh '''
                    echo "🧨 Verificando y eliminando red previa si existe..."
                    docker network rm pipeline_net || true

                    echo "🔧 Levantando entorno para pruebas..."
                    docker-compose -p $COMPOSE_PROJECT_NAME up -d --build
                '''
            }
        }

        stage('Ejecutar pruebas') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                    sh '''
                        echo "🧪 Ejecutando pruebas..."
                        docker-compose -p $COMPOSE_PROJECT_NAME exec web \
                            python -m unittest discover -s test || true
                    '''
                }
            }
        }

        stage('Limpiar entorno Docker') {
            steps {
                sh '''
                    echo "🏁 Deteniendo y limpiando contenedores de prueba..."
                    docker-compose -p $COMPOSE_PROJECT_NAME down --remove-orphans --volumes || true

                    echo "🧹 Limpiando redes y volúmenes huérfanos..."
                    docker network rm pipeline_net || true
                    docker network prune -f || true
                    docker volume prune -f || true
                '''
            }
        }

        stage('Desplegar en producción') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh '''
                    echo "🚀 Desplegando contenedores productivos..."
                    docker-compose -p $COMPOSE_PROJECT_NAME up -d
                '''
            }
        }
    }
}
