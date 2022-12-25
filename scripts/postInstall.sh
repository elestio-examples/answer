#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 30s;

target=$(docker-compose port answer 80)

curl http://${target}/installation/init \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36' \
  --data-raw '{"lang":"en_US","db_type":"sqlite3","db_username":"root","db_password":"root","db_host":"db:3306","db_name":"answer","db_file":"/data/answer.db"}' \
  --compressed



  curl http://${target}/installation/base-info \
    -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36' \
  --data-raw '{"lang":"en_US","site_name":"answer","site_url":"https://'${DOMAIN}'","contact_email":"'${ADMIN_EMAIL}'","name":"admin","password":"'${ADMIN_PASSWORD}'","email":"'${ADMIN_EMAIL}'"}' \
  --compressed


# sed -i "s|http://127.0.0.1:9080|https://${DOMAIN}|g" ./answer-data/data/conf/config.yaml

# docker-compose down;
# docker-compose up -d;
# # echo "Waiting for software to be ready ..."
# sleep 30s;


# First login

login=$(curl http://${target}/answer/api/v1/user/login/email \
  -H 'accept: */*' \
  -H 'accept-language: en_US' \
  -H 'authorization;' \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  --data-raw '{"e_mail":"'${ADMIN_EMAIL}'","pass":"'${ADMIN_PASSWORD}'"}' \
  --compressed)

  access_token=$(echo $login | jq -r '.data.access_token' )


# Configure SMTP
curl http://${target}/answer/admin/api/setting/smtp \
  -X 'PUT' \
  -H 'accept: */*' \
  -H 'accept-language: en_US' \
  -H 'authorization: '"${access_token}"'' \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  --data-raw '{"from_email":"'${DEFAULT_FROM_EMAIL}'","from_name":"answer","smtp_host":"'${EMAIL_HOST}'","encryption":"","smtp_port":'${EMAIL_PORT}',"smtp_authentication":false,"smtp_username":"","smtp_password":"","test_email_recipient":""}' \
  --compressed