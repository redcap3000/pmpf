-- rules for insertions and logging 
 DROP RULE IF EXISTS log_1_block on mp_blocks;
 
  CREATE RULE log_1_block AS ON INSERT TO mp_blocks
    DO INSERT INTO mp_versions (r_id,v_table,v_dat) 
    VALUES 
    (NEW.id-1,
     'mp_blocks',
     array[
     	array['time_updated=>'||cast(localtimestamp as text),
     	'usergroup=>'			||cast(NEW.usergroup as text),
     	'block_name=>'			||cast(NEW.block_name as text),
     	'urls=>'				||cast(NEW.urls as text),
     	'block_type=>'			||cast(NEW.block_type as text),
     	'block_order=>'			||cast(NEW.block_order as text),
     	'block_content=>'			||cast(NEW.b_content as text),
     	'master_select=>'			||cast(NEW.master_select as text),
	'b_options=>'||cast(NEW.b_options as text),
     	'status=>'				||cast(NEW.status as text)]
     	]
     );
                                

DROP TRIGGER IF EXISTS record_update_check on mp_blocks;
 CREATE TRIGGER record_update_check
    BEFORE UPDATE ON mp_blocks
    FOR EACH ROW EXECUTE PROCEDURE suppress_redundant_updates_trigger();


 DROP RULE IF EXISTS update_block ON mp_blocks;
-- now if we are rolling back and update, do we add it to the list ? 
-- this would create a history of sorts, if we have this we should be able to remove values lest 
CREATE RULE update_block AS ON UPDATE TO mp_blocks
    DO UPDATE mp_versions 
    SET   	
    v_dat =    array_cat((select v_dat from mp_versions where r_id = OLD.id),              
				     	array['time_updated=>'||cast(localtimestamp as text),
				     	'usergroup=>'			||cast(compare(NEW.usergroup,OLD.usergroup,'-') as text),
				     	'block_name=>'			||compare(NEW.block_name,OLD.block_name,'-'),
				     	'urls=>'			||compare(NEW.urls,OLD.urls,'-'),
				     	'block_type=>'			||compare((cast(NEW.block_type as text)),(cast(OLD.block_type as text)),'-'),
				     	'block_order=>'			||compare(NEW.block_order,OLD.block_order,'-'),
				     	'block_content=>'			||compare(NEW.b_content,OLD.b_content,'-'),
				     	'master_select=>'			||compare(NEW.master_select,OLD.master_select,'-'),
				     	'block_options=>'			||cast((compare(NEW.b_options,OLD.b_options,array['-']))as text),
				     	'status=>'				||compare((cast(NEW.status as text)),(cast(OLD.status as text)))]
				     	)
           WHERE mp_versions.r_id = OLD.id;
