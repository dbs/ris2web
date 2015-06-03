DROP TABLE author_uri;
CREATE TABLE author_uri (id SERIAL, author INT, uri TEXT, cat TEXT);
CREATE OR REPLACE FUNCTION make_author_uri (author TEXT, uri TEXT, cat TEXT) RETURNS BIGINT AS $$
    INSERT INTO author_uri (author, uri, cat)
        SELECT id, uri, cat FROM authors WHERE author_name = author;
    SELECT lastval();
$$ LANGUAGE SQL;
CREATE OR REPLACE FUNCTION make_author_uri (author TEXT, uri TEXT) RETURNS BIGINT AS $$
    INSERT INTO author_uri (author, uri)
        SELECT id, uri FROM authors WHERE author_name = author;
    SELECT lastval();
$$ LANGUAGE SQL;
CREATE OR REPLACE VIEW author_uri_v AS
    SELECT u.id AS uid, a.id, u.uri, u.cat
    FROM authors a
        INNER JOIN author_uri u ON u.author = a.id;

SELECT make_author_uri('Manley, John', 'http://viaf.org/viaf/104621497');
SELECT make_author_uri('Manley, John', 'http://isni.org/isni/000000007579407X');
SELECT make_author_uri('Palmer, Bryan D.', 'http://viaf.org/viaf/112731920');
SELECT make_author_uri('Palmer, Bryan D.', 'http://isni.org/isni/0000000081802216');
SELECT make_author_uri('Palmer, Bryan D.', 'https://www.trentu.ca/history/publications_palmer.php', 'home');
SELECT make_author_uri('Savage, Larry', 'http://viaf.org/viaf/9654559');
SELECT make_author_uri('Savage, Larry', 'http://isni.org/isni/0000000074200292');
SELECT make_author_uri('Savage, Larry', 'http://www.brocku.ca/social-sciences/departments-and-centres/labour-studies/faculty-members/larry-savage', 'home');
SELECT make_author_uri('Ross, Stephanie', 'http://viaf.org/viaf/4659237');
SELECT make_author_uri('Ross, Stephanie', 'http://isni.org/isni/0000000072663701');
SELECT make_author_uri('Ross, Stephanie', 'http://orcid.org/0000-0003-3669-8263');
SELECT make_author_uri('Ross, Stephanie', 'http://people.laps.yorku.ca/people.nsf/researcherprofile?readform&shortname=stephr', 'home');
SELECT make_author_uri('Vosko, Leah F.', 'http://viaf.org/viaf/9396872');
SELECT make_author_uri('Vosko, Leah F.', 'http://isni.org/isni/0000000114675103');
SELECT make_author_uri('Vosko, Leah F.', 'http://people.laps.yorku.ca/people.nsf/researcherprofile?readform&shortname=lvosko', 'home');
SELECT make_author_uri('Finkel, Alvin', 'http://viaf.org/viaf/111145526');
SELECT make_author_uri('Finkel, Alvin', 'http://isni.org/isni/0000000115803453');
