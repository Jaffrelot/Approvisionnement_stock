-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 24 fév. 2025 à 06:56
-- Version du serveur : 10.4.24-MariaDB
-- Version de PHP : 8.1.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `approvisionnement_stock`
--

-- --------------------------------------------------------

--
-- Structure de la table `approvisionnement`
--

CREATE TABLE `approvisionnement` (
  `idAppr` int(11) NOT NULL,
  `Num_fournisseur` int(11) DEFAULT NULL,
  `Num_produit` int(11) DEFAULT NULL,
  `qteentree` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `approvisionnement`
--

INSERT INTO `approvisionnement` (`idAppr`, `Num_fournisseur`, `Num_produit`, `qteentree`) VALUES
(15, 1, 6, 4),
(17, 1, 11, 5),
(18, 1, 13, 2),
(19, 1, 10, 2);

--
-- Déclencheurs `approvisionnement`
--
DELIMITER $$
CREATE TRIGGER `avant_insertion` BEFORE INSERT ON `approvisionnement` FOR EACH ROW begin
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `avant_modification` BEFORE UPDATE ON `approvisionnement` FOR EACH ROW begin
declare ancien_stock int;
declare ancien_stockModif int;
declare ancien_qte_entree int;
declare nom_fourn varchar(50);
declare design_produit varchar(50);
select nom into nom_fourn from fournisseur where Num_fournisseur=new.Num_fournisseur;
select design into design_produit from produit where Num_produit=new.Num_produit;
select stock into ancien_stock from produit where Num_produit=new.Num_produit;
select stock into ancien_stockModif from produit where Num_produit=old.Num_produit;
select qteentree into ancien_qte_entree from approvisionnement where Num_fournisseur=new.Num_fournisseur and Num_produit=new.Num_produit order by idAppr desc limit 1;
IF new.qteentree < 0 THEN
    SIGNAL sqlstate '45000'
    set message_text = "Le stock est insuffisant";
ELSEIF ancien_qte_entree IS NULL THEN
    set ancien_qte_entree = 0;
    update produit set stock=ancien_stock+new.qteentree-ancien_qte_entree where Num_produit=new.Num_produit;
    update produit set stock=ancien_stockModif-old.qteentree where Num_produit=old.Num_produit;
    insert into audit_approvisionnement set action='UPDATE',date=now(),nom=nom_fourn,design=design_produit,qteentree_ancien=ancien_qte_entree,qteentree_nouv=new.qteentree,utilisateur=@user;        
ELSE
    update produit set stock=ancien_stock+new.qteentree-ancien_qte_entree where Num_produit=new.Num_produit;
    insert into audit_approvisionnement set action='UPDATE',date=now(),nom=nom_fourn,design=design_produit,qteentree_ancien=ancien_qte_entree,qteentree_nouv=new.qteentree,utilisateur=@user;
END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `avant_suppression` BEFORE DELETE ON `approvisionnement` FOR EACH ROW begin
declare ancien_stock int;
declare design_prod varchar(50);
declare nom_fourn varchar(50);
select stock into ancien_stock from produit where Num_produit=old.Num_produit;
select design into design_prod from produit where Num_produit=old.Num_produit;
select nom into nom_fourn from fournisseur where Num_fournisseur=old.Num_fournisseur;
select stock into ancien_stock from produit where Num_produit=old.Num_produit;
update produit set stock=ancien_stock-old.qteentree where Num_produit=old.Num_produit;
insert into audit_approvisionnement set action='DELETE',date=now(),nom=nom_fourn,design=design_prod,qteentree_ancien=old.qteentree,qteentree_nouv=0,utilisateur=@user;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `audit_approvisionnement`
--

CREATE TABLE `audit_approvisionnement` (
  `idAuditAppr` int(11) NOT NULL,
  `action` varchar(50) NOT NULL,
  `date` datetime NOT NULL,
  `nom` varchar(50) NOT NULL,
  `design` varchar(50) NOT NULL,
  `qteentree_ancien` int(11) NOT NULL,
  `qteentree_nouv` int(11) NOT NULL,
  `utilisateur` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `audit_approvisionnement`
--

INSERT INTO `audit_approvisionnement` (`idAuditAppr`, `action`, `date`, `nom`, `design`, `qteentree_ancien`, `qteentree_nouv`, `utilisateur`) VALUES
(32, 'INSERT', '2025-02-22 18:25:42', 'Jack', 'cartable', 0, 6, 'Abrivard'),
(33, 'UPDATE', '2025-02-22 18:26:36', 'Jack', 'ordinateur', 0, 4, 'Abrivard'),
(34, 'INSERT', '2025-02-22 18:49:40', 'Jack', 'ordinateur', 4, 10, 'Bizoux'),
(35, 'DELETE', '2025-02-22 18:50:11', 'Jack', 'ordinateur', 10, 0, 'Bizoux'),
(36, 'INSERT', '2025-02-23 20:56:34', 'Jack', 'Ecran', 0, 5, 'Abrivard'),
(37, 'INSERT', '2025-02-23 20:58:10', 'Jack', 'Cahier', 0, 2, 'Abrivard'),
(38, 'INSERT', '2025-02-23 22:09:00', 'Jack', 'Stylo', 0, 1, 'Abrivard'),
(39, 'UPDATE', '2025-02-23 22:13:21', 'Jack', 'Stylo', 1, 2, 'Abrivard'),
(40, 'UPDATE', '2025-02-23 22:13:43', 'Jack', 'Clavier', 0, 2, 'Abrivard');

-- --------------------------------------------------------

--
-- Structure de la table `audit_produit`
--

CREATE TABLE `audit_produit` (
  `id` int(11) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `userAction` varchar(50) DEFAULT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `audit_produit`
--

INSERT INTO `audit_produit` (`id`, `action`, `userAction`, `date`) VALUES
(1, 'INSERT', '', '2025-02-19 16:25:44'),
(2, 'INSERT', 'user', '2025-02-19 16:28:09'),
(3, 'INSERT', 'elardo', '2025-02-19 16:38:43');

-- --------------------------------------------------------

--
-- Structure de la table `fournisseur`
--

CREATE TABLE `fournisseur` (
  `Num_fournisseur` int(11) NOT NULL,
  `nom` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `fournisseur`
--

INSERT INTO `fournisseur` (`Num_fournisseur`, `nom`) VALUES
(1, 'Jack');

-- --------------------------------------------------------

--
-- Structure de la table `produit`
--

CREATE TABLE `produit` (
  `Num_produit` int(11) NOT NULL,
  `design` varchar(50) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `produit`
--

INSERT INTO `produit` (`Num_produit`, `design`, `stock`) VALUES
(6, 'ordinateur', 68),
(10, 'Clavier', 91),
(11, 'Ecran', 26),
(12, 'Stylo', 19),
(13, 'Cahier', 21),
(14, 'cartable', 26);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','user') NOT NULL DEFAULT 'user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`) VALUES
(1, 'Jaffrelot', '$2y$10$HcJ0Wa6Tozfa37IzathYueDf5eKF4aPZk8em5i6GnSwsbOpyGkDT.', 'admin'),
(4, 'Bizoux', '$2y$10$/28xGiMYQXtBAh.a6M1k/O0FtAoiMRWPpSUvErIcQgYDQmhQe6JLC', 'user'),
(5, 'Abrivard', '$2y$10$B5/KVmFi3EyWvJ2mJxLCnOPJFopkIMUtJj0KC7f3PVRZrxB3TEqq.', 'user');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `approvisionnement`
--
ALTER TABLE `approvisionnement`
  ADD PRIMARY KEY (`idAppr`),
  ADD KEY `Num_fournisseur` (`Num_fournisseur`),
  ADD KEY `Num_produit` (`Num_produit`);

--
-- Index pour la table `audit_approvisionnement`
--
ALTER TABLE `audit_approvisionnement`
  ADD PRIMARY KEY (`idAuditAppr`);

--
-- Index pour la table `audit_produit`
--
ALTER TABLE `audit_produit`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  ADD PRIMARY KEY (`Num_fournisseur`);

--
-- Index pour la table `produit`
--
ALTER TABLE `produit`
  ADD PRIMARY KEY (`Num_produit`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `approvisionnement`
--
ALTER TABLE `approvisionnement`
  MODIFY `idAppr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT pour la table `audit_approvisionnement`
--
ALTER TABLE `audit_approvisionnement`
  MODIFY `idAuditAppr` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT pour la table `audit_produit`
--
ALTER TABLE `audit_produit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `fournisseur`
--
ALTER TABLE `fournisseur`
  MODIFY `Num_fournisseur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `produit`
--
ALTER TABLE `produit`
  MODIFY `Num_produit` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `approvisionnement`
--
ALTER TABLE `approvisionnement`
  ADD CONSTRAINT `approvisionnement_ibfk_1` FOREIGN KEY (`Num_fournisseur`) REFERENCES `fournisseur` (`Num_fournisseur`),
  ADD CONSTRAINT `approvisionnement_ibfk_2` FOREIGN KEY (`Num_produit`) REFERENCES `produit` (`Num_produit`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
