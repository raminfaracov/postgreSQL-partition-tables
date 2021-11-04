CREATE SCHEMA test_partition;

SET default_tablespace = '';

/*	
 sample to create partition by status field, 
 our status field takes only two values  ='a' - active records, ='c' - cancelled records
*/

CREATE TABLE test_partition.main_table (
	id integer NOT NULL,
	name character varying(80),
	surname character varying(100),
	age smallint,
	bdate date,
	insert_date timestamp(0) without time zone,
	status bpchar NOT NULL
)
PARTITION BY LIST (status);


CREATE SEQUENCE test_partition.main_table_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MINVALUE
	NO MAXVALUE
	CACHE 1;


ALTER SEQUENCE test_partition.main_table_id_seq OWNED BY test_partition.main_table.id;


SET default_table_access_method = heap;


-- create first partiotion table for active records 
CREATE TABLE test_partition.main_table_active (
	id integer DEFAULT nextval('test_partition.main_table_id_seq'::regclass) NOT NULL,
	name character varying(80),
	surname character varying(100),
	age smallint,
	bdate date,
	insert_date timestamp(0) without time zone,
	status bpchar NOT NULL
);
ALTER TABLE ONLY test_partition.main_table ATTACH PARTITION test_partition.main_table_active FOR VALUES IN ('a');


-- create second partiotion table for deactive records 
CREATE TABLE test_partition.main_table_deactive (
	id integer DEFAULT nextval('test_partition.main_table_id_seq'::regclass) NOT NULL,
	name character varying(80),
	surname character varying(100),
	age smallint,
	bdate date,
	insert_date timestamp(0) without time zone,
	status bpchar NOT NULL
);
ALTER TABLE ONLY test_partition.main_table ATTACH PARTITION test_partition.main_table_deactive FOR VALUES IN ('c');


ALTER TABLE ONLY test_partition.main_table ALTER COLUMN id SET DEFAULT nextval('test_partition.main_table_id_seq'::regclass);


SELECT pg_catalog.setval('test_partition.main_table_id_seq', 6100000, true);


ALTER TABLE ONLY test_partition.main_table
	ADD CONSTRAINT main_table_pk_id PRIMARY KEY (id, status);


ALTER TABLE ONLY test_partition.main_table_active
	ADD CONSTRAINT main_table_active_pkey PRIMARY KEY (id, status);


ALTER TABLE ONLY test_partition.main_table_deactive
	ADD CONSTRAINT main_table_deactive_pkey PRIMARY KEY (id, status);


CREATE INDEX main_table_age_idx ON ONLY test_partition.main_table USING btree (age);


CREATE INDEX main_table_active_age_idx ON test_partition.main_table_active USING btree (age);


CREATE INDEX main_table_deactive_age_idx ON test_partition.main_table_deactive USING btree (age);


ALTER INDEX test_partition.main_table_age_idx ATTACH PARTITION test_partition.main_table_active_age_idx;


ALTER INDEX test_partition.main_table_pk_id ATTACH PARTITION test_partition.main_table_active_pkey;


ALTER INDEX test_partition.main_table_age_idx ATTACH PARTITION test_partition.main_table_deactive_age_idx;


ALTER INDEX test_partition.main_table_pk_id ATTACH PARTITION test_partition.main_table_deactive_pkey;	
