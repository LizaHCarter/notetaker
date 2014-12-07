CREATE OR REPLACE FUNCTION find_note(uid integer, nid integer)
RETURNS TABLE ("noteId" integer, title varchar, body text, "updatedAt" timestamp, "tagIds" integer[], "tagNames" varchar[], photos varchar[]) AS $$
DECLARE
BEGIN
  CREATE TEMP TABLE note_data ON COMMIT DROP AS
    SELECT n.id AS note_id, n.title, n.body, n.updated_at, array_ag(t.id) AS tag_ids, array_agg(t.name) AS tag_names
    FROM notes n
    LEFT OUTER JOIN notes_tags nt ON n.id = nt.note_id
    LEFT OUTER JOIN tags t ON nt.tag_id = t.id
    WHERE n.id = nid AND n.user_id = uid
    GROUP BY n.id;

  CREATE TEMP TABLE all_photos ON COMMIT DROP AS
    SELECT array_agg(p.url) AS photos, p.note_id
    FROM photos p
    WHERE p.note_id = nid
    GROUP BY p.note_id

  RETURN QUERY
    SELECT nd.note_id AS "noteId", nd.title, nd.body, nd.updated_at AS "updatedAt", nd.tag_ids AS "tagIds", nd.tag_names AS "tagNames", p.photos
    FROM note_data nd
    LEFT OUTER JOIN all_photos p ON p.note_id = nd.note_id;

  END;

  $$ language plpgsql;
