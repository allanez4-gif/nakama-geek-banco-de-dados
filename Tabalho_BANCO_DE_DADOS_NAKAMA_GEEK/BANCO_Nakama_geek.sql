/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: nakama_geek
-- ------------------------------------------------------
-- Server version	13.0.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `ID_categoria` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(80) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES
(1,'Mangás','Volumes de mangás em português'),
(2,'Action Figures','Figuras articuladas e colecionáveis'),
(3,'Camisetas','Camisetas estampadas de animes'),
(4,'Colecionáveis','Chaveiros, canecas e acessórios'),
(5,'Pôsteres','Pôsteres decorativos em A3');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `ID_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `NOME` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `telefone` varchar(20) NOT NULL,
  `endereco` varchar(200) DEFAULT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT current_timestamp(),
  `data_nascimento` date DEFAULT NULL,
  PRIMARY KEY (`ID_cliente`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES
(1,'Alan de Souza','alan.souza@email.com','(21) 98801-1001','Rua das Flores, 120 - Santa Cruz','2026-08-10 10:00:00',NULL),
(2,'Bruno Lima','bruno.lima@email.com','(21) 98802-1002','Av. Brasil, 450 - Campo Grande','2026-08-12 15:30:00',NULL),
(3,'Carla Mendes','carla.mendes@email.com','(21) 98803-1003','Rua do Ouvidor, 33 - Centro','2026-08-20 09:10:00',NULL),
(4,'Diego Alves','diego.alves@email.com','(21) 98804-1004','Estrada da Pedra, 800 - Guaratiba','2026-09-01 18:45:00',NULL),
(5,'Elisa Rocha','elisa.rocha@email.com','(21) 98805-1005','Rua Sete de Setembro, 90 - Bangu','2026-09-03 11:20:00',NULL),
(6,'Felipe Costa','felipe.costa@email.com','(21) 98806-1006','Av. Cesario de Melo, 2100 - Campo Grande','2026-09-10 14:00:00',NULL),
(7,'Gabriela Nunes','gabriela.nunes@email.com','(21) 98807-1007','Rua Barao, 15 - Realengo','2026-09-18 16:25:00',NULL),
(8,'Henrique Dias','henrique.dias@email.com','(21) 98808-1008','Rua Dom Pedro, 77 - Sepetiba','2026-10-05 12:05:00',NULL),
(9,'Isabela Torres','isabela.torres@email.com','(21) 98809-1009','Rua Paraiba, 240 - Santa Cruz','2026-10-20 10:40:00',NULL),
(10,'João Pereira','joao.pereira@email.com','(21) 98810-1010','Av. Joao XXIII, 510 - Santa Cruz','2026-11-01 17:15:00',NULL);
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracao_loja`
--

DROP TABLE IF EXISTS `configuracao_loja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `configuracao_loja` (
  `id_config` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `dados` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`dados`)),
  PRIMARY KEY (`id_config`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracao_loja`
--

LOCK TABLES `configuracao_loja` WRITE;
/*!40000 ALTER TABLE `configuracao_loja` DISABLE KEYS */;
/*!40000 ALTER TABLE `configuracao_loja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_pedido`
--

DROP TABLE IF EXISTS `item_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_pedido` (
  `id_item` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `id_produto` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL DEFAULT 1,
  `preco_unitario` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_item`),
  KEY `id_pedido` (`id_pedido`),
  KEY `id_produto` (`id_produto`),
  CONSTRAINT `1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`ID_pedido`),
  CONSTRAINT `2` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`ID_produto`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`quantidade` > 0),
  CONSTRAINT `CONSTRAINT_2` CHECK (`preco_unitario` > 0)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_pedido`
--

LOCK TABLES `item_pedido` WRITE;
/*!40000 ALTER TABLE `item_pedido` DISABLE KEYS */;
INSERT INTO `item_pedido` VALUES
(1,1,1,2,34.90),
(2,1,9,1,19.90),
(3,2,4,1,189.90),
(4,3,2,1,36.90),
(5,3,3,1,39.90),
(6,4,5,1,219.90),
(7,5,7,2,79.90),
(8,6,6,1,199.90),
(9,7,8,1,74.90),
(10,7,11,2,29.90),
(11,8,10,1,49.90),
(12,8,12,1,29.90),
(13,9,1,3,34.90),
(14,10,4,1,189.90),
(15,10,9,2,19.90),
(16,11,2,1,36.90),
(17,12,2,1,36.90);
/*!40000 ALTER TABLE `item_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagamento`
--

DROP TABLE IF EXISTS `pagamento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagamento` (
  `id_pagamento` int(11) NOT NULL AUTO_INCREMENT,
  `id_pedido` int(11) NOT NULL,
  `forma_pagamento` varchar(40) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pendente',
  `data_pagamento` datetime DEFAULT NULL,
  PRIMARY KEY (`id_pagamento`),
  UNIQUE KEY `id_pedido` (`id_pedido`),
  CONSTRAINT `1` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`ID_pedido`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`valor` > 0),
  CONSTRAINT `CONSTRAINT_2` CHECK (`status` in ('pendente','aprovado','recusado','estornado'))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagamento`
--

LOCK TABLES `pagamento` WRITE;
/*!40000 ALTER TABLE `pagamento` DISABLE KEYS */;
INSERT INTO `pagamento` VALUES
(1,1,'Pix',89.70,'aprovado','2026-09-05 14:35:00'),
(2,2,'Cartão de crédito',189.90,'aprovado','2026-09-12 10:20:00'),
(3,3,'Boleto',76.80,'aprovado','2026-09-21 08:00:00'),
(4,4,'Pix',219.90,'aprovado','2026-10-02 09:10:00'),
(5,5,'Boleto',159.80,'pendente',NULL),
(6,6,'Cartão de crédito',199.90,'recusado','2026-10-15 11:05:00'),
(7,7,'Pix',134.70,'aprovado','2026-10-28 13:50:00'),
(8,10,'Cartão de débito',229.70,'aprovado','2026-11-12 19:05:00'),
(9,9,'Pix',104.70,'aprovado','2026-11-08 12:35:00'),
(10,11,'Pix',36.90,'aprovado','2026-11-16 00:55:12'),
(11,12,'Pix',36.90,'aprovado','2026-11-16 01:39:21');
/*!40000 ALTER TABLE `pagamento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `ID_pedido` int(11) NOT NULL AUTO_INCREMENT,
  `ID_cliente` int(11) NOT NULL,
  `data_pedido` datetime NOT NULL DEFAULT current_timestamp(),
  `status` varchar(30) NOT NULL DEFAULT 'pendente',
  `observacao` text DEFAULT NULL,
  PRIMARY KEY (`ID_pedido`),
  KEY `ID_cliente` (`ID_cliente`),
  CONSTRAINT `1` FOREIGN KEY (`ID_cliente`) REFERENCES `cliente` (`ID_cliente`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`status` in ('pendente','pago','enviado','entregue','cancelado'))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido`
--

LOCK TABLES `pedido` WRITE;
/*!40000 ALTER TABLE `pedido` DISABLE KEYS */;
INSERT INTO `pedido` VALUES
(1,1,'2026-09-05 14:30:00','entregue',NULL),
(2,2,'2026-09-12 10:15:00','entregue',NULL),
(3,3,'2026-09-20 16:40:00','enviado',NULL),
(4,4,'2026-10-02 09:05:00','enviado',NULL),
(5,5,'2026-10-10 18:20:00','pendente',NULL),
(6,6,'2026-10-15 11:00:00','cancelado',NULL),
(7,7,'2026-10-28 13:45:00','pago',NULL),
(8,1,'2026-11-03 15:10:00','pendente',NULL),
(9,8,'2026-11-08 12:30:00','pago',NULL),
(10,2,'2026-11-12 19:00:00','pago',NULL),
(11,3,'2026-11-16 00:55:12','pago',NULL),
(12,3,'2026-11-16 01:39:21','pago',NULL);
/*!40000 ALTER TABLE `pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produto`
--

DROP TABLE IF EXISTS `produto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `produto` (
  `ID_produto` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `estoque` int(11) NOT NULL DEFAULT 0,
  `ID_categoria` int(11) NOT NULL,
  PRIMARY KEY (`ID_produto`),
  KEY `ID_categoria` (`ID_categoria`),
  CONSTRAINT `1` FOREIGN KEY (`ID_categoria`) REFERENCES `categoria` (`ID_categoria`),
  CONSTRAINT `CONSTRAINT_1` CHECK (`preco` > 0),
  CONSTRAINT `CONSTRAINT_2` CHECK (`estoque` >= 0)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produto`
--

LOCK TABLES `produto` WRITE;
/*!40000 ALTER TABLE `produto` DISABLE KEYS */;
INSERT INTO `produto` VALUES
(1,'Mangá Naruto Vol. 1','Primeiro volume da saga ninja',34.90,50,1),
(2,'Mangá One Piece Vol. 1','Início da aventura dos Chapéus de Palha',36.90,38,1),
(3,'Mangá Jujutsu Kaisen Vol. 1','Estreia da série de maldições',39.90,30,1),
(4,'Action Figure Goku','Figura articulada de 18 cm',189.90,15,2),
(5,'Action Figure Luffy','Figura colecionável de 20 cm',219.90,12,2),
(6,'Action Figure Sukuna','Figura com base de efeitos',199.90,10,2),
(7,'Camiseta Akatsuki','Camiseta preta 100% algodão',79.90,60,3),
(8,'Camiseta Chapéus de Palha','Camiseta branca estampada',74.90,45,3),
(9,'Chaveiro Pokébola','Chaveiro de metal',19.90,100,4),
(10,'Caneca Dragon Ball','Caneca de cerâmica 300 ml',49.90,35,4),
(11,'Pôster Vagabond','Pôster A3 em papel couchê',29.90,80,5),
(12,'Pôster Demon Slayer','Pôster A3 em papel couchê',29.90,70,5);
/*!40000 ALTER TABLE `produto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `produto_detalhes`
--

DROP TABLE IF EXISTS `produto_detalhes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `produto_detalhes` (
  `id_detalhe` int(11) NOT NULL AUTO_INCREMENT,
  `id_produto` int(11) NOT NULL,
  `atributos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`atributos`)),
  PRIMARY KEY (`id_detalhe`),
  UNIQUE KEY `id_produto` (`id_produto`),
  CONSTRAINT `1` FOREIGN KEY (`id_produto`) REFERENCES `produto` (`ID_produto`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `produto_detalhes`
--

LOCK TABLES `produto_detalhes` WRITE;
/*!40000 ALTER TABLE `produto_detalhes` DISABLE KEYS */;
INSERT INTO `produto_detalhes` VALUES
(1,1,'{\"autor\": \"Masashi Kishimoto\", \"editora\": \"Panini\", \"paginas\": 200, \"edicao\": \"Primeira\"}'),
(2,2,'{\"autor\": \"Eiichiro Oda\", \"editora\": \"Panini\", \"paginas\": 208}'),
(3,4,'{\"altura_cm\": 18, \"material\": \"PVC\", \"articulado\": true}'),
(4,7,'{\"tamanhos\": [\"P\", \"M\", \"G\"], \"cor\": \"Preto\", \"material\": \"Algodão\"}');
/*!40000 ALTER TABLE `produto_detalhes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'nakama_geek'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-11-16  2:03:13
