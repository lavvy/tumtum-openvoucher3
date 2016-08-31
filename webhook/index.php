
<?php

$data = json_decode(file_get_contents('php://input'), true);
 
$src = $data["repository"]["clone_url"];

$reponame = $data["repository"]["name"];

$cmd ="export REPONAME=".$reponame." && export SRC=".$src." && /webhook.sh";

$out = shell_exec($cmd);

echo $cmd;

?>

