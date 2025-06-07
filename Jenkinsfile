pipeline {
    agent any

    stages {
        stage('Preparar entorno limpio') {
            steps {
                sh(script: '''
                    echo "Deteniendo contenedores de app y db..."
                    docker stop flask-app mysql-db || true
                    docker rm flask-app mysql-db || true

                    echo "Eliminando red app-net si no se usa..."
                    docker network rm app-net || true

                    echo "Limpiando imágenes dangling..."
                    docker image prune -f || true

                    echo "Limpiando volúmenes huérfanos..."
                    docker volume prune -f || true
                ''', shell: '/bin/bash')  
            }
        }

        stage('Ejecutar pruebas unitarias') {
            steps {
                sh '''
                    echo "🔧 Levantando entorno de prueba completo..."
                    # Se usa un solo comando para levantar los servicios.
                    # Docker Compose gestionará el orden de arranque usando 'depends_on'.
                    docker-compose -p pipeline-test up -d --build web db

                    echo "⌛ Esperando que la base de datos esté lista..."
                    # NOTA: Un 'sleep' no es la mejor práctica. Lo ideal es usar un script
                    # que verifique activamente si la base de datos está lista para aceptar conexiones.
                    sleep 15

                    echo "🧪 Ejecutando pruebas unitarias..."
                    # Se crea el log de resultados y se captura el estado
                    docker-compose exec -T web python -m unittest discover -s test -v > resultados_test.log 2>&1 
                    status=$?

                    echo "📄 Resultados de pruebas:"
                    cat resultados_test.log

                    echo "🧹 Apagando entorno de pruebas..."
                    # Se apaga todo el entorno del proyecto de prueba de forma limpia
                    docker-compose -p pipeline-test down --remove-orphans

                    # Se sale con el código de estado de las pruebas para que el pipeline falle si es necesario
                    exit $status
                '''
            }
        }

        stage('Desplegar en producción') {
            // Este stage solo se ejecuta si las pruebas fueron exitosas
            when {
                expression { currentBuild.result == 'SUCCESS' }
            }
            steps {
                sh '''
                    echo "🚀 Desplegando en producción..."
                    # Se especifica desplegar solo 'web' y 'db' para no afectar a Jenkins
                    docker-compose -p biblioteca-poli up -d --build web db
                '''
            }
        }
    }

    post {
        // 'always' se ejecuta siempre, sin importar el resultado del pipeline
        always {
            echo 'Limpiando el workspace...'
            cleanWs()
        }
    }
}
