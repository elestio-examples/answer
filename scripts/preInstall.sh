#set env vars
#set -o allexport; source .env; set +o allexport;

apt install -y jq

# mkdir -p ./data
mkdir ./answer-data

# chown -R 1000:1000 ./data
# chown -R 1000:1000 ./answer-data

