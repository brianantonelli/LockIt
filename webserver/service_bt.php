<?php
    error_reporting(E_ALL);
    ini_set('display_errors', '1');
    require_once('config.php.inc');

    
    $command = $_REQUEST['command'];
    $con = mysql_connect($CONFIG['db_host'], $CONFIG['db_user'], $CONFIG['db_pass']);
    if(!$con){
        die('Could not connect: ' . mysql_error());
    }
    mysql_select_db($CONFIG['db_schema'], $con);
    
    if(isset($command)){
        if($command == 'get_new_commands'){
            $command_results = mysql_query("select * from command_queue where status = 'sent'");
            $commands = array();
            while($row = mysql_fetch_array($command_results)){
                array_push($commands, array(
                    'id'      => $row['id'],
                    'command' => $row['command']
                ));
            }
        
            echo json_encode($commands);
        }
        else if($command == 'update_command'){
            // TODO: Take a set (aka batch) of commands to lighten http traffic
            $id = $_REQUEST['command_id'];
            $code = $_REQUEST['response_code'];
            $payload = $_REQUEST['response_payload'];
            
            $query = sprintf("UPDATE command_queue SET response_code = '%s', response_payload = '%s', status = 'completed', time_processed = now() WHERE id = %s",
                        mysql_real_escape_string($code),
                        mysql_real_escape_string($payload),
                        mysql_real_escape_string($id));

            mysql_query($query);
        }
        else if($command == 'send_push'){
            // TODO
        }
    }
    
    mysql_close($con);
?>
