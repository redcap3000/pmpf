-- also included in pgdb .. soon to be merged into this project

DROP FUNCTION IF EXISTS show_columns(varchar(255));


CREATE FUNCTION show_columns(varchar(255)) returns table(table_catalog text,table_schema text,table_name text,column_name text,ordinal_position int,
column_default text,is_nullable text,data_type text,character_maximum_length int,character_octet_length int,numeric_precision int,numeric_precision_radix int,
numeric_scale int,datetime_precision int,interval_type text,interval_precision text,character_set_catalog text,character_set_schema text,character_set_name text,
collation_catalog text,collation_schema text,collation_name text,domain_catalog text,domain_schema text,domain_name text,udt_catalog text,udt_schema text,
udt_name text,scope_catalog text,scope_schema text,scope_name text,maximum_cardinality int,
dtd_identifier text,is_self_referencing text,is_identity text,identity_generation text,identity_start text,
identity_increment text,identity_maximum text,identity_minimum text,identity_cycle text,is_generated text,generation_expression text,is_updatable text)
	AS $$
	SELECT * FROM information_schema.columns WHERE table_name = $1
	$$
	LANGUAGE SQL;


DROP FUNCTION IF EXISTS show_tables(varchar(255));

CREATE FUNCTION show_tables() returns table(table_catalog text,table_schema text,table_name text,table_type text, self_referencing_column_name text, reference_generation text, user_defined_type_catalog text,user_defined_type_schema text, user_defined_type_name text, is_insertable_into text, is_typed text, commit_action text)
	AS $$
	SELECT * FROM information_schema.tables WHERE table_schema = 'public'
	$$
	LANGUAGE SQL;

DROP FUNCTION IF EXISTS show_table(varchar(255));

CREATE FUNCTION show_table(varchar(255)) RETURNS table(table_catalog varchar(512),table_schema varchar(512),table_name varchar(512),table_type varchar(512), self_referencing_column_name varchar(512),
 reference_generation varchar(512), user_defined_type_catalog varchar(512),user_defined_type_schema varchar(512),
 user_defined_type_name varchar(512), is_insertable_into varchar(3), is_typed varchar(3), commit_action varchar(512))
	AS $$
	SELECT * FROM information_schema.tables WHERE table_schema = 'public' and table_name = $1
	$$
	LANGUAGE SQL;

DROP FUNCTION IF EXISTS get_options(varchar(255));

CREATE FUNCTION get_options(varchar(255)) returns table(option_value text)
	AS $$
	SELECT cast(b_options[1:array_lower(b_options,1)][1] as text) from mp_blocks
	WHERE urls = $1 or urls = '*'
$$
LANGUAGE SQL;

DROP FUNCTION IF EXISTS get_url(varchar(255),varchar(255));

CREATE FUNCTION  get_url(varchar(255),varchar(255)) returns  TABLE(b_content text,b_options text[])
	AS $$
  	SELECT b_content,b_options 
  	FROM mp_blocks INNER JOIN mp_groups ON (mp_blocks.usergroup= mp_groups.id) INNER JOIN mp_users ON (username = $2)   	
  	WHERE status = 'active' 
  	AND	  group_level >=  (select group_level from mp_groups where mp_groups.id = mp_users.usergroup) or mp_blocks.usergroup = NULL
  	AND	  urls = cast($1 as text)
	AND (b_options IS NULL or b_options[1:array_upper(b_options,1)][1:1] <@ array['page_title','no_cache','additive_title','logout'])
  	GROUP BY block_order,mp_blocks.id,b_content,b_options
    	ORDER BY block_order,mp_blocks.id
    
    $$
    LANGUAGE SQL;  
  
 DROP FUNCTION IF EXISTS get_url(varchar(255));

 CREATE FUNCTION get_url(varchar(255)) RETURNS TABLE(b_content text,b_options text[])
    	AS $$ 
    	SELECT b_content,b_options
    	FROM mp_blocks 
    	WHERE urls = CAST($1 AS text) and (usergroup is null or usergroup = 3)
    	AND (b_options IS NULL or b_options[1:array_upper(b_options,1)][1:1] <@ array['page_title','no_cache','additive_title','logout'])
    	GROUP BY block_order,id,b_content,b_options
    	ORDER BY block_order,id
    $$
    LANGUAGE SQL;  
    -- fix the way arrays get interpreted ... hmmm either here or the php, probably better here than in a language
  --make json/xml/atom output functions ! wouldn't that be rad!     
  DROP FUNCTION IF EXISTS get_blocks_version(int,int); 
 CREATE FUNCTION get_blocks_version(int,int) RETURNS TABLE(v_id int,r_id int,time_updated text[],usergroup text[],block_name text[],urls text[],block_type text[],block_order text[], block_content text[], master_select text[], block_options text[], status text[],dimensions text)
    	AS $$ 
    	SELECT  v_id,r_id,
    		string_to_array(v_dat[$1][1],'=>'),
    		string_to_array(v_dat[$1][2],'=>'),
    		string_to_array(v_dat[$1][3],'=>'),
    		string_to_array(v_dat[$1][4],'=>'),
    		string_to_array(v_dat[$1][5],'=>'),
    		string_to_array(v_dat[$1][6],'=>'),
    		string_to_array(v_dat[$1][7],'=>'),
    		string_to_array(v_dat[$1][8],'=>'),    
   		string_to_array(v_dat[$1][9],'=>'),		
    		string_to_array(v_dat[$1][10],'=>'),
    		array_dims(v_dat[$1][1:1]) || array_upper(v_dat,1) as dimensions
    	FROM mp_versions
    	WHERE r_id = $2 and v_table = 'mp_blocks';  
    
    $$
    LANGUAGE SQL;
