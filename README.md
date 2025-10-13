# Tracker

Web application for requirements management in software development projects.

## Functionality

1. Features
2. User Stories
3. Tasks
4. Workers (assignees)
5. Work logs
6. Budget report
7. Payouts to workers

## Development

1. Run these lines:

```shell
rbenv install $(cat .ruby-version)
bundle install
cd .tools; bundle install; cd ..
bin/overcommit --install
bin/overcommit --sign post-checkout
bin/overcommit --sign post-commit
bin/overcommit --sign pre-commit
bin/configs
```

2. Change value for database URL in file `config/settings/local.yml`

3. Run `bin/setup`

4. Remove file `.solargraph.yml` in root directory if it was created.
