CREATE OR REPLACE FUNCTION add_photos(url_string varchar, nid integer)
RETURNS integer AS $$
DECLARE
  result integer;
  urls varchar[];
  pic_url varchar;
BEGIN
  SELECT string_to_array(url_string, ',') INTO urls;
  RAISE NOTICE 'urls: %', urls;
  FOREACH pic_url IN ARRAY urls
    LOOP
      INSERT INTO photos (url, note_id) VALUES (pic_url, nid) RETURNING id INTO result;
    END LOOP;

  RETURN result;

END;

$$ language plpgsql;
