# DB Migrator Smoke test
CSIT docker compose for db-migrator can be used for this or any other docker compose.

- Check if `*-tests.sh` have the correct variables.
- Add any extras tests necessary for the test.
- Change the `db_migrator_policy_init.sh` on db-migrator docker to the `*-test.sh` file.
- Run docker compose
- Collect logs with `docker-compose logs > results.txt`
- Tear down compose. Repeat process if necessary.