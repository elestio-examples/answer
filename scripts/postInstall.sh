#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 30s;

target=$(docker-compose port answer 80)


sed -i "s|http://127.0.0.1:9080|https://${DOMAIN}|g" ./answer-data/data/conf/config.yaml


docker-compose down;
docker-compose up -d;


# First login

login=$(curl http://${target}/answer/api/v1/user/login/email \
  -H 'accept: */*' \
  -H 'accept-language: en_US' \
  -H 'authorization;' \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  --data-raw '{"e_mail":"admin@admin.com","pass":"admin"}' \
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
  --data-raw '{"from_email":"'"${DEFAULT_FROM_EMAIL}"'","from_name":"answer","smtp_host":"'"${EMAIL_HOST}"'","encryption":"","smtp_port":'"${EMAIL_PORT}"',"smtp_authentication":true,"smtp_username":"'"${EMAIL_HOST_USER}"'","smtp_password":"'"${EMAIL_HOST_PASSWORD}"'","test_email_recipient":""}' \
  --compressed

# curl http://${target}/answer/admin/api/setting/smtp \
#   -X 'PUT' \
#   -H 'accept: */*' \
#   -H 'accept-language: en_US' \
#   -H 'authorization: '"${access_token}"'' \
#   -H 'content-type: application/json' \
#   -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
#   --data-raw '{"from_email":"answer@vm.elestio.app","from_name":"answer","smtp_host":"172.17.0.1","encryption":"","smtp_port":25,"smtp_authentication":true,"smtp_username":"","smtp_password":"","test_email_recipient":""}' \
#   --compressed


#   changing email addresse

curl http://${target}/answer/api/v1/user/email/change/code \
  -H 'accept: */*' \
  -H 'accept-language: en_US' \
  -H 'authorization: '"${access_token}"'' \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  --data-raw '{"e_mail":"'"${ADMIN_EMAIL}"'"}' \
  --compressed


#   Changing passwords

curl http://${target}/answer/api/v1/user/password \
  -X 'PUT' \
  -H 'accept: */*' \
  -H 'accept-language: en_US' \
  -H 'authorization: '"${access_token}"'' \
  -H 'content-type: application/json' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
  --data-raw '{"old_pass":"admin","pass":"'"${ADMIN_PASSWORD}"'"}' \
  --compressed




  