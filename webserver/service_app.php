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
        if($command == 'register'){
            $udid = $_REQUEST['udid'];
            $device_token = $_REQUEST['device_token'];
            $ip = $_SERVER['REMOTE_ADDR'];
            
            $query = sprintf("INSERT INTO users(udid, device_token, ip_address) VALUES('%s', '%s', '%s')",
                        mysql_real_escape_string($udid),
                        mysql_real_escape_string($device_token),
                        mysql_real_escape_string($ip));
            mysql_query($query);
            
            echo json_encode(array());
        }
        else if($command == 'send_command'){
            $device_token = $_REQUEST['device_token'];
            $execute_command = $_REQUEST['execute_command'];

            $query = sprintf("INSERT INTO command_queue(device_token, command) VALUES('%s', '%s')",
                        mysql_real_escape_string($device_token),
                        mysql_real_escape_string($execute_command));

            mysql_query($query);
            
            echo json_encode(array());
        }
    }
    
    mysql_close($con);
?>
