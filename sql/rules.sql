-- rules for insertions and logging 
 DROP RULE IF EXISTS log_1_block on mp_blocks;
 
  CREATE RULE log_1_block AS ON INSERT TO mp_blocks
    DO INSERT INTO pmpf_versions (r_id,v_table,v_dat) 
    VALUES 
    (NEW.id-1,
     'mp_blocks',
     array[
     	array['time_updated=>'||cast(localtimestamp as text),
     	'usergroup=>'			||cast(NEW.usergroup as text),
     	'b_name=>'			||cast(NEW.block_name as text),
     	'urls=>'				||cast(NEW.urls as text),
     	'b_type=>'			||cast(NEW.b_type as text),
     	'b_order=>'			||cast(NEW.b_order as text),
     	'b_content=>'			||cast(NEW.b_content as text),
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
    DO UPDATE pmpf_versions 
    SET   	
    v_dat =    array_cat((select v_dat from pmpf_versions where r_id = OLD.id),              
				     	array['time_updated=>'||cast(localtimestamp as text),
				     	'usergroup=>'			||cast(compare(NEW.usergroup,OLD.usergroup,'-') as text),
				     	'b_name=>'			||compare(NEW.b_name,OLD.b_name,'-'),
				     	'urls=>'			||compare(NEW.urls,OLD.urls,'-'),
				     	'b_type=>'			||compare((cast(NEW.b_type as text)),(cast(OLD.b_type as text)),'-'),
				     	'b_order=>'			||compare(NEW.b_order,OLD.b_order,'-'),
				     	'b_content=>'			||compare(NEW.b_content,OLD.b_content,'-'),
				     	'master_select=>'			||compare(NEW.master_select,OLD.master_select,'-'),
				     	'b_options=>'			||cast((compare(NEW.b_options,OLD.b_options,array['-']))as text),
				     	'status=>'				||compare((cast(NEW.status as text)),(cast(OLD.status as text)))]
				     	)
           WHERE pmpf_versions.r_id = OLD.id;
