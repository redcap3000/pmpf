<?php
require('pgdb.php');
// Call this object instead of pgdb
class pmpf extends pgdb{
	public $db;
	function __construct($username,$pass,$database){
		if(!$this->db)
			parent::__construct($database,$username,$pass);
		}

	function get_url($url,$username=NULL,$password=NULL){
		if($username != NULL && $password == NULL)
			$return = "select * from get_url('$url','$username')";
			// already authorized ... may want to check on session key
		elseif(username != NULL && $password !=NULL)
		{
			// log userin /pass token create cookie ??
		}
		else{
			// unauthorized user
			$return = "select * from get_url('$url')";
		}
		return self::make_assoc_array(self::get_objects($return));
        }

        function make_assoc_array($result,$row_name = 'b_options'){
	/*  
	Converts a column that contains an array into object parameters provided a result set from get_objects() and the name of the column(s)
	that conform to the standards listed below.  First define your column as a multimdensional array ex : text[][]. When creating
	array sets structure them as such array[[parameter,value],[parameter2,value2]]
	Coded /serialized string aren't used to allow for easier sorting , selection, and
	conditional checking via SQL functions/tiggers/selections etc.
	*/
                if(strpos($row_name,',') > 0) $row_name = explode(',',$row_name);
                if(!is_array($row_name)){
                        foreach($result as  $loc=>$row){
                                unset($options);
                                if($row->$row_name != '')$options[]=array_filter(explode('}',$row->$row_name));
                                if($options){
                                foreach($options as $item){
                                        foreach($item as $opt){
                                                $opt = str_replace(array('"','{'),'',$opt);
                                                $opt = explode(',',trim($opt, ','));
                                                $row->$opt[0] = $opt[1];
                                        }
                                 unset($row->$row_name);
                                $result[$loc] = $row;
                                }
                                }
                        }
                }
                else
                        foreach($row_name as $row_name2)
                                foreach($result as $row)
                                        if($row->row_name2 != '')$options[]=array_filter(explode('}',$row->$row_name2));
                foreach($options as $item){
                        foreach($item as $opt){
                                $opt = str_replace(array('"','{'),'',$opt);
                                $opt = explode(',',trim($opt, ','));
                                $output [$opt[0]] = $opt[1];
                        }
                }
                return ($result?$result:0);
	}

        function get_blocks_version($version,$record){
                $result = self::get_assoc("select get_blocks_version($version,$record);");
                foreach(explode('}","',$result[0]['get_blocks_version']) as $key=>$value){
                        if($key != 0 ){
                                echo ("\n$key => $value\n");
                                $result[$key] = str_replace(array('","','{',',,','""'), '', $value);
                                $result[$key] = explode(',',$result[$key]);

                                if($result[$key][0] != '")' && $result[$key][0] != '"')
                                        $result[$result[$key][0]] = $result[$key][1];
                                elseif($result[$key][0] == '"'){
                                        $result['loc'] =explode('][1:1]',$result[$key][1]);
                                        $result['loc'] = str_replace(array('1:','['),'',$result['loc'][0]) . ' of ' .str_replace(')','',$result['loc'][1]) ;
                                        //unset($result[$key][0]);
                                        }
                        }else{
                                $result[$key] = explode(',"{',$value);
                                $result[$key][0] = explode(',',$result[$key][0]);
                                $result['v_id'] = str_replace('(','',$result[$key][0][0]);
                                $result['r_id'] = str_replace('(','',$result[$key][0][1]);
                                $result['time_updated'] = str_replace(array('time_updated,','""'),'',$result[$key][1]);
                        }
                        unset($result[$key]);
                }
                return $result;
        }
}

// Enter your postgres data here
//$pmpf = new pmpf('postgres','pass','dbname');


