#!/bin/bash
set -e

command=$1

NETWORK="qa-performance"
VOLUME_NAME_1="sitespeed-result"
VOLUME_NAME_2="sitespeed-config"
VOLUME_NAME_3="sitespeed-script"

DIR_1="${HOME}/data/piqaautomationstorage/sitespeed-result"
DIR_2="${PWD}/config"
DIR_3="${PWD}/script"


export HOST_IP=`curl -s https://checkip.amazonaws.com`
export IMAGE_TAG="dev"

function login(){
    ./pi-container-registry.sh login
    docker pull pageintegrity.azurecr.io/pi-core/pi-qa-performance-backend:${IMAGE_TAG}
    docker pull pageintegrity.azurecr.io/pi-core/pi-qa-performance-frontend:${IMAGE_TAG}
}

function up(){
    login

    echo "HOST_IP   : $HOST_IP"
    echo "IMAGE_TAG : $IMAGE_TAG"


    # make sure we use the latest images
    # docker-compose -f docker-compose.yaml pull
    # run in 'detach' mode (up -d)
    docker-compose -f docker-compose.yaml up -d 
}
function down(){
    docker-compose -f docker-compose.yaml down 
}
function exec(){
    SERVICE_NAME=$1

    echo ""
    echo "Connecting to '$SERVICE_NAME' service (container). To exit the container, type 'exit'."
    echo ""
    docker-compose exec $SERVICE_NAME /bin/bash
}

function delete_volumes() {

    if docker volume ls | grep -q $VOLUME_NAME_1 ; then
        echo ""
        echo "Remove docker volume $VOLUME_NAME_1"
        docker volume rm $VOLUME_NAME_1
    fi

    if docker volume ls | grep -q $VOLUME_NAME_2 ; then
        echo ""
        echo "Remove docker volume $VOLUME_NAME_2"
        docker volume rm $VOLUME_NAME_2
    fi

    if docker volume ls | grep -q $VOLUME_NAME_3 ; then
        echo ""
        echo "Remove docker volume $VOLUME_NAME_3"
        docker volume rm $VOLUME_NAME_3
    fi
}

function create_directory(){
    DIR="$1"
    if [[ ! -d "$DIR" ]];then
        echo ""
        echo "Creating directory '$DIR'"
        mkdir -p "$DIR"
    fi
}
function create_volumes() {

    create_directory "$DIR_1"
    create_directory "$DIR_2"
    create_directory "$DIR_3"

    echo ""
    echo "Create volume $VOLUME_NAME_1"
    # --opt device=/home/mukundhan/share \
    # --opt device=./${PWD}/data/piqaautomationstorage/sitespeed-result \
    docker volume create --driver local \
        --opt type=none \
        --opt device=${DIR_1} \
        --opt o=bind $VOLUME_NAME_1

    echo ""
    echo "Create volume $VOLUME_NAME_2"
    docker volume create --driver local \
        --opt type=none \
        --opt device=${DIR_2} \
        --opt o=bind $VOLUME_NAME_2

    echo ""
    echo "Create volume $VOLUME_NAME_3"
    docker volume create --driver local \
        --opt type=none \
        --opt device=${DIR_3} \
        --opt o=bind $VOLUME_NAME_3
}

__usage="
Usage: $(basename $0) [OPTIONS]

Options:
  up                            Start the application
  dn, down                      Stop the application
  logs <service-name>           Get the logs of the specified service
  be, backend                   Connect to 'backend' service (ppen a bash terminal in the container)
  fe, frontend                  Connect to 'front' service (ppen a bash terminal in the container)
  h, help                       Get help
"

case $command in 
    "up")
        if ! docker network ls | grep -q $NETWORK; then
            echo ""
            echo "Starting application ..."
            echo ""

            delete_volumes
            create_volumes
            up    
        fi
        echo ""
        echo "Application is up."
        ;;
    "down"|"dn")
        # if docker network ls | grep -q $NETWORK ; then
        #     down
        #     delete_volumes
        # fi  
        down
        delete_volumes

        echo ""
        echo "Application is down."
        ;;
    "backend"|"be")
        exec "server";;
    "frontend"|"fe")
        exec "client";;
    "logs" )
        SERVICE_NAME=$2
        case $SERVICE_NAME in
            "backend"|"be")
                SERVICE_NAME="server";;
            "frontend"|"fe")
                SERVICE_NAME="client";;
        esac
        docker-compose logs --follow $SERVICE_NAME 
    ;;
    "info" )
        echo ""
        echo "Executing 'docker-compose ps' ..."
        echo ""
        docker-compose ps

        echo ""
        echo "Executing 'docker-compose top' ..."
        echo ""
        docker-compose top


        ;;
    "help"|"h" )
        echo "$__usage"
        ;;
    * )
        echo "Invalid command '$command'."
esac

