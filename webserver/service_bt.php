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
            $status = $_REQUEST['status'];
            $payload = $_REQUEST['payload'];
            
            $query = sprintf("UPDATE command_queue SET response_code = '%s', response_payload = '%s', status = '%s', time_processed = now() WHERE id = %s",
                        mysql_real_escape_string($code),
                        mysql_real_escape_string($payload),
                        mysql_real_escape_string($status),
                        mysql_real_escape_string($id));
echo $query;
            mysql_query($query);
            echo json_encode(array());
        }
        else if($command == 'send_push'){
            // TODO
        }
        else if($command == 'send_state'){
            $state = $_REQUEST['state'];
            
            $query = sprintf("UPDATE command_queue SET response_code = '200', response_payload = '%s', status = 'completed', time_processed = now() WHERE command = 'GetState' AND status = 'received'", $state);
            echo $query;
            mysql_query($query);
            echo json_encode(array());
        }
    }
    
    mysql_close($con);
?>
