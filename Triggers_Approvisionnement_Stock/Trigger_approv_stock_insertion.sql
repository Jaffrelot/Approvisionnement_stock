DELIMITER $$
create trigger avant_insertion
before insert on approvisionnement
for each row
begin
declare ancien_stock int;
declare ancien_qte_entree int;
declare nom_fourn varchar(50);
declare design_produit varchar(50);
select nom into nom_fourn from fournisseur where Num_fournisseur=new.Num_fournisseur;
select design into design_produit from produit where Num_produit=new.Num_produit;
select stock into ancien_stock from produit where Num_produit=new.Num_produit;
select qteentree into ancien_qte_entree from approvisionnement where Num_fournisseur=new.Num_fournisseur and Num_produit=new.Num_produit order by idAppr desc limit 1;
IF new.qteentree < 0 THEN
    SIGNAL sqlstate '45000'
    set message_text = "Le stock est insuffisant";    
ELSEIF ancien_qte_entree IS NULL THEN
    set ancien_qte_entree = 0;
    update produit set stock=ancien_stock+new.qteentree where Num_produit=new.Num_produit;
    insert into audit_approvisionnement set action='INSERT',date=now(),nom=nom_fourn,design=design_produit,qteentree_ancien=ancien_qte_entree,qteentree_nouv=new.qteentree,utilisateur=@user;
ELSE
    update produit set stock=ancien_stock+new.qteentree where Num_produit=new.Num_produit;
    insert into audit_approvisionnement set action='INSERT',date=now(),nom=nom_fourn,design=design_produit,qteentree_ancien=ancien_qte_entree,qteentree_nouv=new.qteentree,utilisateur=@user;
END IF;
END$$
