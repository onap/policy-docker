bash ../gen_truststore.sh
bash ../gen_keystore.sh

source ./get-versions.sh

docker-compose up -d policy-gui

