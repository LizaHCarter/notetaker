CREATE TABLE users(
  id SERIAL PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password CHAR(60) NOT NULL,
  avatar VARCHAR(500) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE notes(
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  user_id INTEGER NOT NULL REFERENCES users(id)
);

CREATE TABLE tags(
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE notes_tags(
  note_id INTEGER NOT NULL REFERENCES notes(id),
  tag_id INTEGER NOT NULL REFERENCES tags(id)
);

CREATE TABLE photos(
  id SERIAL PRIMARY KEY,
  url VARCHAR(500) NOT NULL,
  note_id INTEGER NOT NULL REFERENCES notes(id)
);

CREATE OR REPLACE FUNCTION add_note(user_id integer, title varchar, body text, tags varchar)
RETURNS integer AS $$
DECLARE
nid integer;
tid integer;
names varchar[];
tagname varchar;
BEGIN
-- insert the note
INSERT INTO notes (title, body, user_id) VALUES (title, body, user_id) RETURNING id INTO nid;
-- turn string into array
SELECT string_to_array(tags, ',') INTO names;
RAISE NOTICE 'nid: %', nid;
RAISE NOTICE 'names: %', names;
-- create temp table
create temp table tagger on commit drop as select nid, t.id as tid, t.name as tname from tags t where t.name = any(names);
  -- looping over all the tags
  foreach tagname in array names
  loop
  tid := (select t.tid from tagger t where t.tname = tagname);
  raise notice 'tid: %', tid;
  -- if the tag does not exist, then insert it
  IF tid is null then
  insert into tags (name) values (tagname) returning id into tid;
    insert into tagger values (nid, tid, tagname);
      end if;
      end loop;
      -- take the temp table and insert it into the join table
      insert into notes_tags select t.nid, t.tid from tagger t;
        -- return the note id
        return nid;
        end;
        $$ language plpgsql;

        CREATE OR REPLACE FUNCTION add_photos(url_string varchar, nid integer)
        RETURNS integer AS $$
        DECLARE
        result integer;
        urls varchar[];
        pic_url varchar;
        BEGIN
        -- turn string into array
        SELECT string_to_array(url_string, ',') INTO urls;
        RAISE NOTICE 'urls: %', urls;
        FOREACH pic_url IN ARRAY urls
        LOOP
        INSERT INTO photos (url,note_id) VALUES (pic_url, nid) RETURNING id INTO result;
        END LOOP;
        RETURN result;
        end;
        $$ language plpgsql;

        CREATE OR REPLACE FUNCTION query_notes (uid integer, lmt integer, ofst integer)
        RETURNS TABLE ("noteId" integer, title varchar, body text, "updatedAt" timestamp, "tagIds" integer[], "tagNames" varchar[]) AS $$
        DECLARE
        BEGIN
        RETURN QUERY
        SELECT n.id AS "noteId", n.title, n.body, n.updated_at AS "updatedAt", array_agg(t.id) AS "tagIds", array_agg(t.name) AS "tagNames"
        FROM notes n
        LEFT OUTER JOIN notes_tags nt ON n.id = nt.note_id
        LEFT OUTER JOIN tags t ON nt.tag_id = t.id
        WHERE n.user_id = uid
        GROUP BY n.id
        ORDER BY n.updated_at DESC
        OFFSET ofst
        LIMIT lmt;

        END;
        $$ language plpgsql;

        CREATE OR REPLACE FUNCTION find_note(uid integer, nid integer)
        RETURNS TABLE ("noteId" integer, title varchar, body text, "updatedAt" timestamp, "tagIds" integer[], "tagNames" varchar[], photos varchar[]) AS $$
        DECLARE
        BEGIN

        CREATE TEMP TABLE note_data ON COMMIT DROP AS
        SELECT n.id AS note_id, n.title, n.body, n.updated_at, array_agg(t.id) AS tag_ids, array_agg(t.name) AS tag_names
        FROM notes n
        LEFT OUTER JOIN notes_tags nt ON n.id = nt.note_id
        LEFT OUTER JOIN tags t ON nt.tag_id = t.id
        WHERE n.id = nid AND n.user_id = uid
        GROUP BY n.id;

        CREATE TEMP TABLE all_photos ON COMMIT DROP AS
        SELECT array_agg(p.url) AS photos, p.note_id
        FROM photos p
        WHERE p.note_id = nid
        GROUP BY p.note_id;

        RETURN QUERY
        SELECT nd.note_id AS "noteId", nd.title, nd.body, nd.updated_at AS "updatedAt", nd.tag_ids AS "tagIds", nd.tag_names AS "tagNames", p.photos
        FROM note_data nd
        LEFT OUTER JOIN all_photos p ON p.note_id = nd.note_id;

        END;
        $$ language plpgsql;
