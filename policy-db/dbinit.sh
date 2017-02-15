#sed -i '/^bind-address/s/127\.0\.0\.1/0.0.0.0/' /etc/mysql/my.cnf
cat >/etc/mysql/conf.d/policy.cnf <<-'EOF'
	[mysqld]
	lower_case_table_names = 1
	bind-address = 0.0.0.0
EOF

echo "Starting mysqld"
service mysql start

echo "Run mysql_secure_installation"
/usr/bin/mysql_secure_installation <<-EOF

	y
	secret
	secret
	y
	y
	y
	y
EOF

echo "Creating db schemas and user"
mysql -uroot -psecret <<-EOF
	create database xacml;
	create database log;
	create database support;
	create table support.db_version(the_key varchar(20) not null, version varchar(20), primary key(the_key));
	insert into support.db_version values('VERSION', '00');
	insert into support.db_version values('DROOLS_VERSION', '00');
	create user 'policy_user'@'localhost' identified by 'policy_user';
	grant all privileges on *.* to 'policy_user'@'localhost' with grant option;
	flush privileges;
	select * from support.db_version;
EOF

echo "Stopping mysqld"
service mysql stop
