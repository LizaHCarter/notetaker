CREATE TABLE photos(
  id serial primary key,
  url varchar(500) not null,
  note_id integer not null references notes(id)
);
