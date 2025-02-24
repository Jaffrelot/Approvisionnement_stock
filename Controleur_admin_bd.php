<?php

require ('Model_admin_bd.php');


                                        // DANS LA TABLE PRODUIT


$action = $_GET["action"] ?? '';

if($action === 'liste_produit'){
    $reqListeProduit = "SELECT *from produit";
    
    $liste_produit=$connect->query($reqListeProduit);
    $resultat=$liste_produit->fetchAll();

    echo json_encode($resultat);
}


elseif($action === 'recupererIdProduit'){
    $num=$_GET["IdProduit"];
    $reqId = "SELECT *from produit where Num_produit='$num'";
    
    $IdRecuperer=$connect->query($reqId);
    $resultat=$IdRecuperer->fetchAll();

    echo json_encode($resultat);

}

elseif($action === 'Ajouter_produit' && $_SERVER["REQUEST_METHOD"] === 'POST'){
    session_start();

    $Design=$_POST["design"];
    $Stock=$_POST["stock"];

    $username = $_SESSION['anarana'];
    $connect->query("SET @user = '$username'");

    
    $req_ajout_prod = "INSERT into produit(design,stock) values(:design,:stock);";
    
    $insertion=$connect->prepare($req_ajout_prod);  // préparation
   
    
    $insertion->bindParam(":design",$Design);
    $insertion->bindParam(":stock",$Stock);

    $insertion->execute();  //excecution

}


elseif($action === 'Modifier_produit' && $_SERVER["REQUEST_METHOD"] === 'POST'){
    
    
    $idModif=$_POST["idProduit"];
    $EditDesign=$_POST["edit_design"];
    $EditStock=$_POST["edit_stock"];

    $reqIdEdit = "UPDATE produit set design='$EditDesign',stock='$EditStock' where Num_produit='$idModif'";
    
    $Modifier=$connect->query($reqIdEdit);
    $resultat=$Modifier->fetchAll();

    echo json_encode($resultat);

}

elseif($action === 'SupprimerProduit' && $_SERVER["REQUEST_METHOD"] === 'DELETE'){
    
    $idSuppr=$_GET["IdSupprProd"];

    $reqIdSuppr = "DELETE from produit where Num_produit='$idSuppr'";
    
    $Suppression=$connect->query($reqIdSuppr);
    $resultat=$Suppression->fetchAll();

    echo json_encode($resultat);

}




elseif($action === 'promote_user' && $_SERVER["REQUEST_METHOD"] === 'POST'){


$userId = $_POST['id'];

$stmt = $connect->prepare("UPDATE users SET role = 'admin' WHERE id = ?");
$stmt->execute([$userId]);

echo json_encode(['success' => true, 'message' => 'Utilisateur promu en admin']);
}




                                                    // TABLE APPROVISIONNEMENT
                                                    

if($action === 'liste_approvisionnement'){
    $reqListeAppr = "SELECT *from approvisionnement";
    
    $liste_approvisionnement=$connect->query($reqListeAppr);
    $resultat=$liste_approvisionnement->fetchAll();

    echo json_encode($resultat);
}

elseif($action === 'recupererIdAppr'){
    $num=$_GET["IdAppr"];
    $reqId = "SELECT *from approvisionnement where idAppr='$num'";
    
    $IdRecuperer=$connect->query($reqId);
    $resultat=$IdRecuperer->fetchAll();

    echo json_encode($resultat);

}
elseif($action === 'ListeFrs'){

    $req = "SELECT *from fournisseur";
    
    $listeFournisseur=$connect->query($req);
    $resultat=$listeFournisseur->fetchAll();

    echo json_encode($resultat);

}
elseif($action === 'ListeProduit'){

    $req = "SELECT *from produit";
    
    $listeProduit=$connect->query($req);
    $resultat=$listeProduit->fetchAll();

    echo json_encode($resultat);

}

elseif($action === 'Ajouter_approvisionnement' && $_SERVER["REQUEST_METHOD"] === 'POST'){
    session_start();

    $NumFrs=$_POST["Num_Frs"];
    $NumProd=$_POST["Num_Prod"];
    $QteEntree=$_POST["Qteentree"];

    $username = $_SESSION['anarana'];
    $connect->query("SET @user = '$username'");

    
    $req_ajout_appr = "INSERT into approvisionnement(Num_fournisseur,Num_produit,qteentree) values(:numFrs,:numProd,:qteEntree);";
    
    $insertion=$connect->prepare($req_ajout_appr);  // préparation
   
    
    $insertion->bindParam(":numFrs",$NumFrs);
    $insertion->bindParam(":numProd",$NumProd);
    $insertion->bindParam(":qteEntree",$QteEntree);

    $insertion->execute();  //excecution

}


elseif($action === 'Modifier_approvisionnement' && $_SERVER["REQUEST_METHOD"] === 'POST'){

    session_start();

    $idAppr=$_POST["id"];
    $NumFrs=$_POST["edit_idFrs"];
    $NumProd=$_POST["edit_idProd"];
    $qteentree=$_POST["edit_qte"];

    $username = $_SESSION['anarana'];
    $connect->query("SET @user = '$username'");

   

    $reqIdEdit = "UPDATE approvisionnement set Num_fournisseur='$NumFrs',Num_produit='$NumProd',qteentree='$qteentree' where idAppr='$idAppr'";
    
    $Modifier=$connect->query($reqIdEdit);
    $resultat=$Modifier->fetchAll();

    echo json_encode($resultat);
    

}


elseif($action === 'SupprimerApprovisionnement' && $_SERVER["REQUEST_METHOD"] === 'DELETE'){
    session_start();

    $idSuppr=$_GET["IdSupprAppr"];

    $username = $_SESSION['anarana'];
    $connect->query("SET @user = '$username'");

    

    $reqIdSuppr = "DELETE from approvisionnement where idAppr='$idSuppr'";
    
    $Suppression=$connect->query($reqIdSuppr);
    $resultat=$Suppression->fetchAll();

    echo json_encode($resultat);

}


                                                // TABLE AUDIT APPROVISIONNEMENT

if($action === 'liste_audit_approvisionnement'){
    $reqListeAuditAppr = "SELECT *from audit_approvisionnement";
    
    $liste_audit_approvisionnement=$connect->query($reqListeAuditAppr);
    $resultat=$liste_audit_approvisionnement->fetchAll();

    echo json_encode($resultat);
}

elseif($action === 'nombreInsertion'){

    $reqNbrInsert = "SELECT count(*) as nbrInsertion from audit_approvisionnement where action='INSERT'";
    
    $NbrInsertion=$connect->query($reqNbrInsert);
    $resultat=$NbrInsertion->fetchAll();

    echo json_encode($resultat);

}
elseif($action === 'nombreModification'){

    $reqNbrUpdate = "SELECT count(*) as nbrModification from audit_approvisionnement where action='UPDATE'";
    
    $NbrModification=$connect->query($reqNbrUpdate);
    $resultat=$NbrModification->fetchAll();

    echo json_encode($resultat);

}
elseif($action === 'nombreSuppression'){

    $reqNbrDelete = "SELECT count(*) as nbrSuppression from audit_approvisionnement where action='DELETE'";
    
    $NbrSuppression=$connect->query($reqNbrDelete);
    $resultat=$NbrSuppression->fetchAll();

    echo json_encode($resultat);

}



                                                    // AUTHENTIFICATION

elseif($action === 'liste_utilisateur'){
    $reqListeUsers = "SELECT *from users";
    
    $liste_utilisateurs=$connect->query($reqListeUsers);
    $resultat=$liste_utilisateurs->fetchAll();

    echo json_encode($resultat);

}




elseif($action === 'SeConnecter' && $_SERVER["REQUEST_METHOD"] === 'POST'){
    session_start();

    $username=$_POST["Username"];
    $password=$_POST["pwd"];                                                

    $reqAuthentifier="SELECT *FROM users where username='$username'";
    $FoundUser=$connect->query($reqAuthentifier);
    $user=$FoundUser->fetch();


    if($user && password_verify($password,$user["password"])){
        $_SESSION['anarana'] = $username;
        $_SESSION['role'] = $user["role"];
        echo json_encode(["message" => "Connexion reussie","role" => $_SESSION['role']]);
    }
    else{
        echo json_encode(["message" => "Identifiant incorrect"]);
    }


}


elseif($action === 'session' && $_SERVER["REQUEST_METHOD"] === 'GET'){

    session_start();

    if(isset($_SESSION['anarana'])){
    
        echo json_encode(["authenticated" => true,"role" => $_SESSION['role']]);
   
    }

    else
    {
        echo json_encode(["authenticated" => false]);
    }


}


elseif($action === 'Deconnexion'){

session_start();    
// On supprime ttes les variables de la session
session_unset();
// On détruit totalement la session
session_destroy();

}





?>