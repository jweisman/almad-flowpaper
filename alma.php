<?php

require $_ENV["DOCROOT"].'/libs/aws/aws-autoloader.php';

function CallAPI($url)
{
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_HTTPHEADER, array(
        'Authorization: apikey ' . $_ENV["ALMA_API_KEY"],
        'Accept: application/json'
    ));

    $url_prefix = "https://api-na.hosted.exlibrisgroup.com/almaws/v1";

    curl_setopt($curl, CURLOPT_URL, $url_prefix . $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);

    $result = curl_exec($curl);

    curl_close($curl);
    return json_decode($result,true);
}

require_once("lib/config.php"); 

$configManager = new Config();
$pdfpath = $configManager->getConfig('path.pdf');
$swfpath = $configManager->getConfig('path.swf');
$bucket = 'na-st01.ext.exlibrisgroup.com';
$rep_id = $_GET["rep_id"];

if ($rep_id == '') {
    print "Representation ID required.";
    exit;
}

$bib = CallAPI('/bibs?view=brief&representation_id='.$rep_id);
$mms_id = $bib['bib'][0]['mms_id']; 
$files = CallAPI('/bibs/'.$mms_id.'/representations/'.$rep_id.'/files');
$keyname = $files['representation_file'][0]['path'];
$fileloc = $pdfpath.$rep_id.'/'.basename($keyname);

if (!file_exists($fileloc)) {
    $s3 = new Aws\S3\S3Client([
        'version' => 'latest',
        'region'  => 'us-east-1'
    ]);

    if (!file_exists($swfpath)) {
        mkdir($swfpath, 0777, true);
    }

    if (!file_exists(dirname($fileloc))) {
        mkdir(dirname($fileloc), 0777, true);
    }

    $result = $s3->getObject(array(
        'Bucket' => $bucket,
        'Key'    => $keyname,
        'SaveAs' => $fileloc
    ));
}

$url = 'simple_document.php?subfolder='.$rep_id.'/&doc='.urlencode(basename($keyname));
header("Location: $url");
exit;