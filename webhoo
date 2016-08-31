<?php

$data = json_decode(file_get_contents('php://input'), true);
 
$src = $data["repository"]["clone_url"];

$name = "/var/www/html/".$data["repository"]["name"];

$cmd = "git clone ".$src." && cd ".$name." && chmod 777 -R ".$name." && ./run.sh";

$out = shell_exec($cmd);

echo $cmd;

?>
