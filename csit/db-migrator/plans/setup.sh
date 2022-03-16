echo "Uninstall docker-py and reinstall docker."
python3 -m pip uninstall -y docker-py
python3 -m pip uninstall -y docker
python3 -m pip install -U docker
python3 -m pip install -U robotframework-databaselibrary
python3 -m pip install psycopg2-binary

sudo apt-get -y install libxml2-utils

source "${SCRIPTS}"/get-versions.sh

cd "${SCRIPTS}"
docker-compose -f "${SCRIPTS}"/compose-postgres.yml up -d

sleep 15
unset http_proxy https_proxy

POSTGRES_IP=$(get-instance-ip.sh postgres)
POLICY_API_IP=$(get-instance-ip.sh policy-api)

echo POSTGRES IP IS "${POSTGRES_IP}"
echo POLICY_API_IP IS "${POLICY_API_IP}"

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POSTGRES_IP:${POSTGRES_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"