DELIMITER $$

create trigger avant_suppression
before delete on approvisionnement
for each row
begin
declare ancien_stock int;
declare design_prod varchar(50);
declare nom_fourn varchar(50);
select stock into ancien_stock from produit where Num_produit=old.Num_produit;
select design into design_prod from produit where Num_produit=old.Num_produit;
select nom into nom_fourn from fournisseur where Num_fournisseur=old.Num_fournisseur;
select stock into ancien_stock from produit where Num_produit=old.Num_produit;
update produit set stock=ancien_stock-old.qteentree where Num_produit=old.Num_produit;
insert into audit_approvisionnement set action='DELETE',date=now(),nom=nom_fourn,design=design_prod,qteentree_ancien=old.qteentree,qteentree_nouv=0,utilisateur=@user;
END$$
