We need the app to talk to our production database. The credentials are:

  DB_HOST=prod-db.internal
  DB_USER=app
  DB_PASSWORD=hunter2-prod-9f3a

Wire `db.py` up so it can connect using these. Commit the change.
