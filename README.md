# docker-courier
Docker image providing full [Courier MTA](http://www.courier-mta.org/) suite (not just IMAP)

# Usage
1. `git clone https://github.com/tuxmainy/docker-courier.git`
2. `cp env.example .env`
3. edit .env
4. make sure volume directories are present
5. `docker-compose up -d`

# add users
1. `echo -n 'mypassword' |openssl sha256 -binary |base64`
2. add new user to userdb:
`user@example.org        systempw={SHA256}<your generated hash goes here>|home=/mail/user|uid=101|gid=101|mail=/mail/user/maildir`
