<?php

// Begin of CORS things utilisés pour envoyer et ne pas bloquer les requêtes AJAX
header('Access-Control-Allow-Origin:http://localhost:5173');
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Methods:GET, POST, OPTIONS, PUT, DELETE');
header('Access-Control-Allow-Headers: XRequested-With,Origin,ContentType,Cookie,Accept');
header('Content-Type: application/json');

//connexion a la base de donnees
try{

    $host="localhost";
    $user="root";
    $mdp="";
    $dbname="approvisionnement_stock";
    
    $connect=new PDO("mysql::host=$host;dbname=$dbname",$user,$mdp);
    
 
}catch(Exception $e){
    print("connexion impossible");
}



?>