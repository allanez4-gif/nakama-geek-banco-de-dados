-- ==========================================================================
-- NAKAMA GEEK - BANCO DE DADOS (MariaDB)
-- Tema: loja de mangas e produtos geek
-- Atividade: Criacao e Manipulacao de Objetos no MySQL / MariaDB (Aula 11)
-- ==========================================================================
--
-- COMO EXECUTAR
--   Abra este arquivo no DBeaver e rode tudo de uma vez (Alt+X).
--   O script recria o banco do zero, entao pode ser executado varias vezes.
--   As linhas que comecam com "-- " e tem um comando depois sao testes de
--   erro ou comandos finais (DROP): rode-as manualmente, so se quiser.
--
-- ESTRUTURA (alinhada as partes 3 a 11 do roteiro)
--   3 CREATE | 4 INSERT | 5 SELECT | 6 JOIN | 7 ALTER
--   8 UPDATE/DELETE | 9 JSON | 10 TRANSACOES | 11 DROP
--
-- DECISOES DE DESIGN (resumo)
--   1. Seis tabelas principais, uma por entidade do DER: CLIENTE, PEDIDO,
--      PAGAMENTO, ITEM_PEDIDO, PRODUTO e CATEGORIA. Sem dados repetidos
--      (modelo normalizado).
--   2. ITEM_PEDIDO e uma tabela associativa: um pedido tem varios produtos
--      e um produto aparece em varios pedidos (relacao N:N resolvida em
--      duas relacoes 1:N).
--   3. ITEM_PEDIDO.preco_unitario guarda o preco NO MOMENTO da compra. Se o
--      produto for reajustado depois, o historico do pedido nao muda.
--   4. PAGAMENTO e 1:1 com PEDIDO, garantido por UNIQUE em id_pedido.
--      Simplificacao consciente: nao permite pagamento parcelado em varios
--      registros nem nova tentativa apos recusa.
--   5. Integridade pelo proprio banco: NOT NULL, UNIQUE, DEFAULT e CHECK
--      (preco e estoque validos, quantidade maior que zero, status dentro
--      de uma lista), em vez de depender so da aplicacao.
--   6. Chaves estrangeiras SEM ON DELETE CASCADE: o banco impede apagar um
--      cliente que tem pedidos, o que protege o historico de vendas.
--   7. Status como VARCHAR com CHECK, em vez de tabela propria: mais simples
--      para o escopo. Em um sistema maior, uma tabela de status seria mais
--      flexivel.
--   8. DECIMAL(10,2) para dinheiro (evita erro de arredondamento do FLOAT).
--   9. JSON em tabelas separadas (PRODUTO_DETALHES e CONFIGURACAO_LOJA):
--      guarda atributos que variam por produto (autor do manga, tamanhos da
--      camiseta) sem criar colunas para cada caso. Limitacao: o banco nao
--      valida os campos internos do JSON.
--  10. Transacoes agrupam passos que precisam acontecer juntos, como uma
--      venda: criar pedido, criar item, baixar estoque e registrar
--      pagamento. Ou tudo vale (COMMIT) ou nada vale (ROLLBACK).
--
-- TIPOS DE DADOS USADOS
--   INT .......... ids, quantidade, estoque
--   VARCHAR ...... nome, email, telefone, status, forma_pagamento
--   DECIMAL ...... preco, preco_unitario, valor
--   DATE ......... CLIENTE.data_nascimento
--   DATETIME ..... data_cadastro, data_pedido, data_pagamento
--   BOOLEAN ...... PRODUTO.destaque
--   TEXT ......... PEDIDO.observacao
--   JSON ......... PRODUTO_DETALHES.atributos, CONFIGURACAO_LOJA.dados
-- ==========================================================================


-- ==========================================================================
-- PARTE 3: IMPLEMENTACAO FISICA (CREATE DATABASE E CREATE TABLE)
-- ==========================================================================

-- Recria o banco do zero para o script poder ser rodado varias vezes.
DROP DATABASE IF EXISTS nakama_geek;

CREATE DATABASE nakama_geek
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;

USE nakama_geek;


-- --------------------------------------------------------------------------
-- CLIENTE: quem compra na loja.
-- UNIQUE no email: dois clientes nao podem ter o mesmo email.
-- DEFAULT CURRENT_TIMESTAMP: a data de cadastro e preenchida sozinha.
-- --------------------------------------------------------------------------
CREATE TABLE CLIENTE (
    id_cliente      INT AUTO_INCREMENT,
    nome            VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL,
    telefone        VARCHAR(20)  NOT NULL,
    endereco        VARCHAR(200),
    data_cadastro   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_nascimento DATE         NULL,

    CONSTRAINT pk_cliente       PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);


-- --------------------------------------------------------------------------
-- CATEGORIA: agrupa os produtos (mangas, action figures, camisetas...).
-- --------------------------------------------------------------------------
CREATE TABLE CATEGORIA (
    id_categoria INT AUTO_INCREMENT,
    nome         VARCHAR(80) NOT NULL,
    descricao    VARCHAR(255),

    CONSTRAINT pk_categoria      PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nome UNIQUE (nome)
);


-- --------------------------------------------------------------------------
-- PRODUTO: itens vendidos pela loja.
-- CHECK: preco maior que zero e estoque nunca negativo.
-- destaque BOOLEAN: marca produtos em destaque (padrao FALSE).
-- --------------------------------------------------------------------------
CREATE TABLE PRODUTO (
    id_produto   INT AUTO_INCREMENT,
    id_categoria INT          NOT NULL,
    nome         VARCHAR(150) NOT NULL,
    descricao    VARCHAR(255),
    preco        DECIMAL(10,2) NOT NULL,
    estoque      INT           NOT NULL DEFAULT 0,
    destaque     BOOLEAN       NOT NULL DEFAULT FALSE,

    CONSTRAINT pk_produto           PRIMARY KEY (id_produto),
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
        REFERENCES CATEGORIA (id_categoria),
    CONSTRAINT chk_produto_preco    CHECK (preco > 0),
    CONSTRAINT chk_produto_estoque  CHECK (estoque >= 0)
);


-- --------------------------------------------------------------------------
-- PEDIDO: compra feita por um cliente.
-- CHECK no status: so aceita os valores da lista.
-- observacao TEXT: anotacao livre e longa sobre o pedido.
-- --------------------------------------------------------------------------
CREATE TABLE PEDIDO (
    id_pedido   INT AUTO_INCREMENT,
    id_cliente  INT         NOT NULL,
    data_pedido DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status      VARCHAR(30) NOT NULL DEFAULT 'pendente',
    observacao  TEXT        NULL,

    CONSTRAINT pk_pedido         PRIMARY KEY (id_pedido),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE (id_cliente),
    CONSTRAINT chk_pedido_status CHECK (
        status IN ('pendente', 'pago', 'enviado', 'entregue', 'cancelado')
    )
);


-- --------------------------------------------------------------------------
-- ITEM_PEDIDO: produtos dentro de um pedido (tabela associativa N:N).
-- preco_unitario guarda o preco do produto no momento da compra.
-- --------------------------------------------------------------------------
CREATE TABLE ITEM_PEDIDO (
    id_item        INT AUTO_INCREMENT,
    id_pedido      INT           NOT NULL,
    id_produto     INT           NOT NULL,
    quantidade     INT           NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_item_pedido      PRIMARY KEY (id_item),
    CONSTRAINT fk_item_pedido      FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO (id_pedido),
    CONSTRAINT fk_item_produto     FOREIGN KEY (id_produto)
        REFERENCES PRODUTO (id_produto),
    CONSTRAINT chk_item_quantidade CHECK (quantidade > 0),
    CONSTRAINT chk_item_preco      CHECK (preco_unitario > 0)
);


-- --------------------------------------------------------------------------
-- PAGAMENTO: pagamento de um pedido.
-- UNIQUE em id_pedido: no maximo um pagamento por pedido (relacao 1:1).
-- --------------------------------------------------------------------------
CREATE TABLE PAGAMENTO (
    id_pagamento    INT AUTO_INCREMENT,
    id_pedido       INT           NOT NULL,
    forma_pagamento VARCHAR(40)   NOT NULL,
    valor           DECIMAL(10,2) NOT NULL,
    status          VARCHAR(30)   NOT NULL DEFAULT 'pendente',
    data_pagamento  DATETIME      NULL,

    CONSTRAINT pk_pagamento        PRIMARY KEY (id_pagamento),
    CONSTRAINT uq_pagamento_pedido UNIQUE (id_pedido),
    CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido)
        REFERENCES PEDIDO (id_pedido),
    CONSTRAINT chk_pagamento_valor CHECK (valor > 0),
    CONSTRAINT chk_pagamento_status CHECK (
        status IN ('pendente', 'aprovado', 'recusado', 'estornado')
    )
);


-- Conferir a criacao: deve listar 6 tabelas.
SHOW TABLES;

DESCRIBE CLIENTE;
DESCRIBE CATEGORIA;
DESCRIBE PRODUTO;
DESCRIBE PEDIDO;
DESCRIBE ITEM_PEDIDO;
DESCRIBE PAGAMENTO;


-- ==========================================================================
-- PARTE 4: INSERT (INSERCAO DE DADOS)
-- A ordem importa: primeiro as tabelas que nao dependem de nenhuma outra
-- (CATEGORIA, CLIENTE), depois as que dependem delas.
-- ==========================================================================

INSERT INTO CATEGORIA (id_categoria, nome, descricao) VALUES
(1, 'Mangás', 'Volumes de mangás em português'),
(2, 'Action Figures', 'Figuras articuladas e colecionáveis'),
(3, 'Camisetas', 'Camisetas estampadas de animes'),
(4, 'Colecionáveis', 'Chaveiros, canecas e acessórios'),
(5, 'Pôsteres', 'Pôsteres decorativos em A3');


-- Os clientes 9 e 10 nao terao pedidos (usados no LEFT JOIN da Parte 6).
INSERT INTO CLIENTE
(id_cliente, nome, email, telefone, endereco, data_cadastro, data_nascimento)
VALUES
(1, 'Ana Souza', 'ana.souza@email.com', '(21) 98801-1001',
    'Rua das Flores, 120 - Santa Cruz', '2026-08-10 10:00:00', '1998-04-12'),
(2, 'Bruno Lima', 'bruno.lima@email.com', '(21) 98802-1002',
    'Av. Brasil, 450 - Campo Grande', '2026-08-12 15:30:00', '2001-09-30'),
(3, 'Carla Mendes', 'carla.mendes@email.com', '(21) 98803-1003',
    'Rua do Ouvidor, 33 - Centro', '2026-08-20 09:10:00', '1995-12-05'),
(4, 'Diego Alves', 'diego.alves@email.com', '(21) 98804-1004',
    'Estrada da Pedra, 800 - Guaratiba', '2026-09-01 18:45:00', '2003-02-18'),
(5, 'Elisa Rocha', 'elisa.rocha@email.com', '(21) 98805-1005',
    'Rua Sete de Setembro, 90 - Bangu', '2026-09-03 11:20:00', '1999-07-21'),
(6, 'Felipe Costa', 'felipe.costa@email.com', '(21) 98806-1006',
    'Av. Cesario de Melo, 2100 - Campo Grande', '2026-09-10 14:00:00', '2000-11-09'),
(7, 'Gabriela Nunes', 'gabriela.nunes@email.com', '(21) 98807-1007',
    'Rua Barao, 15 - Realengo', '2026-09-18 16:25:00', '1997-03-27'),
(8, 'Henrique Dias', 'henrique.dias@email.com', '(21) 98808-1008',
    'Rua Dom Pedro, 77 - Sepetiba', '2026-10-05 12:05:00', '2002-06-14'),
(9, 'Isabela Torres', 'isabela.torres@email.com', '(21) 98809-1009',
    'Rua Paraiba, 240 - Santa Cruz', '2026-10-20 10:40:00', '1996-01-08'),
(10, 'João Pereira', 'joao.pereira@email.com', '(21) 98810-1010',
    'Av. Joao XXIII, 510 - Santa Cruz', '2026-11-01 17:15:00', '2004-10-22');


-- destaque nao e informado: usa o DEFAULT (FALSE). Sera alterado na Parte 8.
INSERT INTO PRODUTO
(id_produto, id_categoria, nome, descricao, preco, estoque)
VALUES
(1, 1, 'Mangá Naruto Vol. 1', 'Primeiro volume da saga ninja', 34.90, 50),
(2, 1, 'Mangá One Piece Vol. 1', 'Início da aventura dos Chapéus de Palha', 36.90, 40),
(3, 1, 'Mangá Jujutsu Kaisen Vol. 1', 'Estreia da série de maldições', 39.90, 30),
(4, 2, 'Action Figure Goku', 'Figura articulada de 18 cm', 189.90, 15),
(5, 2, 'Action Figure Luffy', 'Figura colecionável de 20 cm', 219.90, 12),
(6, 2, 'Action Figure Sukuna', 'Figura com base de efeitos', 199.90, 10),
(7, 3, 'Camiseta Akatsuki', 'Camiseta preta 100% algodão', 79.90, 60),
(8, 3, 'Camiseta Chapéus de Palha', 'Camiseta branca estampada', 74.90, 45),
(9, 4, 'Chaveiro Pokébola', 'Chaveiro de metal', 19.90, 100),
(10, 4, 'Caneca Dragon Ball', 'Caneca de cerâmica 300 ml', 49.90, 35),
(11, 5, 'Pôster Vagabond', 'Pôster A3 em papel couchê', 29.90, 80),
(12, 5, 'Pôster Demon Slayer', 'Pôster A3 em papel couchê', 29.90, 70);


-- observacao (TEXT) preenchida em alguns pedidos; nos demais fica NULL.
INSERT INTO PEDIDO (id_pedido, id_cliente, data_pedido, status, observacao)
VALUES
(1, 1, '2026-09-05 14:30:00', 'entregue', 'Primeira compra da cliente'),
(2, 2, '2026-09-12 10:15:00', 'entregue', NULL),
(3, 3, '2026-09-20 16:40:00', 'enviado', NULL),
(4, 4, '2026-10-02 09:05:00', 'pago', NULL),
(5, 5, '2026-10-10 18:20:00', 'pendente', 'Cliente pediu embalagem para presente'),
(6, 6, '2026-10-15 11:00:00', 'cancelado', 'Pagamento recusado no cartão'),
(7, 7, '2026-10-28 13:45:00', 'pago', NULL),
(8, 1, '2026-11-03 15:10:00', 'pendente', NULL),
(9, 8, '2026-11-08 12:30:00', 'pago', NULL),
(10, 2, '2026-11-12 19:00:00', 'pago', NULL);


INSERT INTO ITEM_PEDIDO
(id_item, id_pedido, id_produto, quantidade, preco_unitario)
VALUES
(1, 1, 1, 2, 34.90),
(2, 1, 9, 1, 19.90),
(3, 2, 4, 1, 189.90),
(4, 3, 2, 1, 36.90),
(5, 3, 3, 1, 39.90),
(6, 4, 5, 1, 219.90),
(7, 5, 7, 2, 79.90),
(8, 6, 6, 1, 199.90),
(9, 7, 8, 1, 74.90),
(10, 7, 11, 2, 29.90),
(11, 8, 10, 1, 49.90),
(12, 8, 12, 1, 29.90),
(13, 9, 1, 3, 34.90),
(14, 10, 4, 1, 189.90),
(15, 10, 9, 2, 19.90);


-- O valor de cada pagamento e a soma dos itens do pedido.
-- O pedido 8 fica sem pagamento (ainda pendente).
INSERT INTO PAGAMENTO
(id_pagamento, id_pedido, forma_pagamento, valor, status, data_pagamento)
VALUES
(1, 1, 'Pix', 89.70, 'aprovado', '2026-09-05 14:35:00'),
(2, 2, 'Cartão de crédito', 189.90, 'aprovado', '2026-09-12 10:20:00'),
(3, 3, 'Boleto', 76.80, 'aprovado', '2026-09-21 08:00:00'),
(4, 4, 'Pix', 219.90, 'aprovado', '2026-10-02 09:10:00'),
(5, 5, 'Boleto', 159.80, 'pendente', NULL),
(6, 6, 'Cartão de crédito', 199.90, 'recusado', '2026-10-15 11:05:00'),
(7, 7, 'Pix', 134.70, 'aprovado', '2026-10-28 13:50:00'),
(8, 9, 'Pix', 104.70, 'aprovado', '2026-11-08 12:35:00'),
(9, 10, 'Cartão de débito', 229.70, 'aprovado', '2026-11-12 19:05:00');


-- Conferir as quantidades. Esperado: 5, 10, 12, 10, 15, 9
SELECT 'CATEGORIA' AS tabela, COUNT(*) AS total FROM CATEGORIA
UNION ALL
SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL
SELECT 'PRODUTO', COUNT(*) FROM PRODUTO
UNION ALL
SELECT 'PEDIDO', COUNT(*) FROM PEDIDO
UNION ALL
SELECT 'ITEM_PEDIDO', COUNT(*) FROM ITEM_PEDIDO
UNION ALL
SELECT 'PAGAMENTO', COUNT(*) FROM PAGAMENTO;


-- ==========================================================================
-- PARTE 5: CONSULTAS SELECT (WHERE, ORDER BY, LIKE, BETWEEN, IN)
-- ==========================================================================

-- Todos os produtos
SELECT * FROM PRODUTO;

-- Colunas especificas, com apelido (AS)
SELECT nome AS produto, preco
FROM PRODUTO;

-- WHERE: produtos com preco maior que 100
SELECT nome, preco
FROM PRODUTO
WHERE preco > 100;

-- WHERE com AND: action figures (categoria 2) com estoque abaixo de 15
SELECT nome, preco, estoque
FROM PRODUTO
WHERE id_categoria = 2
AND estoque < 15;

-- ORDER BY: do mais caro para o mais barato
SELECT nome, preco
FROM PRODUTO
ORDER BY preco DESC;

-- LIMIT: os tres produtos mais caros
SELECT nome, preco
FROM PRODUTO
ORDER BY preco DESC
LIMIT 3;

-- LIKE: o % significa "qualquer coisa"
SELECT nome
FROM PRODUTO
WHERE nome LIKE 'Action Figure%';

SELECT nome, email
FROM CLIENTE
WHERE email LIKE '%@email.com';

-- BETWEEN: intervalo (inclui as pontas)
SELECT nome, preco
FROM PRODUTO
WHERE preco BETWEEN 30 AND 80;

SELECT id_pedido, data_pedido
FROM PEDIDO
WHERE data_pedido BETWEEN '2026-10-01 00:00:00' AND '2026-10-31 23:59:59';

-- IN: lista de valores
SELECT nome, preco
FROM PRODUTO
WHERE id_categoria IN (1, 2, 5);

SELECT id_pedido, status
FROM PEDIDO
WHERE status IN ('pago', 'enviado');

-- GROUP BY: pedidos por status
SELECT status, COUNT(*) AS total
FROM PEDIDO
GROUP BY status;

-- Media de preco por categoria
SELECT id_categoria,
       COUNT(*) AS qtd_produtos,
       AVG(preco) AS preco_medio
FROM PRODUTO
GROUP BY id_categoria;


-- ==========================================================================
-- PARTE 6: JOINS
-- INNER JOIN: so o que tem correspondencia nos dois lados.
-- LEFT JOIN: tudo da tabela da esquerda, mesmo sem correspondencia.
-- ==========================================================================

-- 1) INNER JOIN: pedidos com o nome do cliente
SELECT p.id_pedido,
       c.nome AS cliente,
       p.data_pedido,
       p.status
FROM PEDIDO p
INNER JOIN CLIENTE c
ON c.id_cliente = p.id_cliente;

-- 2) INNER JOIN: produtos com o nome da categoria
SELECT pr.nome AS produto,
       ca.nome AS categoria,
       pr.preco
FROM PRODUTO pr
INNER JOIN CATEGORIA ca
ON ca.id_categoria = pr.id_categoria;

-- 3) LEFT JOIN: clientes que nunca fizeram pedido (esperado: Isabela e Joao)
SELECT c.nome, p.id_pedido
FROM CLIENTE c
LEFT JOIN PEDIDO p
ON p.id_cliente = c.id_cliente
WHERE p.id_pedido IS NULL;

-- 4) LEFT JOIN: todos os pedidos, com ou sem pagamento
-- (forma_pagamento NULL = pedido sem pagamento registrado)
SELECT p.id_pedido,
       p.status AS status_pedido,
       pg.forma_pagamento,
       pg.status AS status_pagamento
FROM PEDIDO p
LEFT JOIN PAGAMENTO pg
ON pg.id_pedido = p.id_pedido;

-- 5) INNER JOIN de 3 tabelas: pedidos, clientes e pagamentos
SELECT p.id_pedido,
       c.nome AS cliente,
       p.status,
       pg.forma_pagamento
FROM PEDIDO p
INNER JOIN CLIENTE c
ON c.id_cliente = p.id_cliente
INNER JOIN PAGAMENTO pg
ON pg.id_pedido = p.id_pedido;

-- 6) INNER JOIN de 4 tabelas: o que cada cliente comprou
SELECT p.id_pedido,
       c.nome AS cliente,
       pr.nome AS produto,
       ip.quantidade,
       ip.preco_unitario,
       (ip.quantidade * ip.preco_unitario) AS subtotal
FROM PEDIDO p
INNER JOIN CLIENTE c
ON c.id_cliente = p.id_cliente
INNER JOIN ITEM_PEDIDO ip
ON ip.id_pedido = p.id_pedido
INNER JOIN PRODUTO pr
ON pr.id_produto = ip.id_produto
ORDER BY p.id_pedido;

-- 7) JOIN com SUM e GROUP BY: total de cada pedido
-- (confira com a coluna valor da tabela PAGAMENTO)
SELECT p.id_pedido,
       c.nome AS cliente,
       SUM(ip.quantidade * ip.preco_unitario) AS total
FROM PEDIDO p
INNER JOIN CLIENTE c
ON c.id_cliente = p.id_cliente
INNER JOIN ITEM_PEDIDO ip
ON ip.id_pedido = p.id_pedido
GROUP BY p.id_pedido, c.nome
ORDER BY p.id_pedido;

-- 8) LEFT JOIN com COUNT: quantos pedidos cada cliente fez
SELECT c.nome,
       COUNT(p.id_pedido) AS qtd_pedidos
FROM CLIENTE c
LEFT JOIN PEDIDO p
ON p.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome;


-- ==========================================================================
-- PARTE 7: ALTER TABLE
-- Ciclo completo em uma coluna de teste: ADD, MODIFY, CHANGE e DROP.
-- No fim a tabela volta ao formato original.
-- ==========================================================================

-- ADD: adicionar coluna
ALTER TABLE CLIENTE
ADD COLUMN observacao TEXT NULL;

DESCRIBE CLIENTE;

-- MODIFY: mudar o tipo da coluna
ALTER TABLE CLIENTE
MODIFY COLUMN observacao VARCHAR(200) NULL;

DESCRIBE CLIENTE;

-- CHANGE: renomear a coluna (precisa repetir o tipo)
ALTER TABLE CLIENTE
CHANGE COLUMN observacao observacoes VARCHAR(200) NULL;

DESCRIBE CLIENTE;

-- DROP COLUMN: remover a coluna
ALTER TABLE CLIENTE
DROP COLUMN observacoes;

DESCRIBE CLIENTE;


-- ==========================================================================
-- PARTE 8: UPDATE E DELETE
-- IMPORTANTE: sempre usar WHERE, senao o comando atinge a tabela inteira.
-- ==========================================================================

-- UPDATE: corrigir nome e email do cliente 1
UPDATE CLIENTE
SET nome = 'Alan de Souza',
    email = 'alan.souza@email.com'
WHERE id_cliente = 1;

-- UPDATE: marcar os produtos 1 e 2 como destaque (BOOLEAN)
UPDATE PRODUTO
SET destaque = TRUE
WHERE id_produto IN (1, 2);

-- UPDATE: mudar o status do pedido 4
UPDATE PEDIDO
SET status = 'enviado'
WHERE id_pedido = 4;

-- Conferir
SELECT id_cliente, nome, email FROM CLIENTE WHERE id_cliente = 1;
SELECT id_produto, nome, destaque FROM PRODUTO WHERE destaque = TRUE;
SELECT id_pedido, status FROM PEDIDO WHERE id_pedido = 4;

-- DELETE em uma tabela de teste (nao toca nos dados do projeto)
CREATE TABLE TESTE_DELETE (
    id INT PRIMARY KEY,
    descricao VARCHAR(100)
);

INSERT INTO TESTE_DELETE (id, descricao)
VALUES (1, 'Registro para testar DELETE');

DELETE FROM TESTE_DELETE
WHERE id = 1;

SELECT * FROM TESTE_DELETE;

DROP TABLE TESTE_DELETE;

-- TESTE DE INTEGRIDADE (erro esperado, rodar manualmente):
-- o cliente 1 tem pedidos, entao o banco bloqueia o DELETE (erro 1451).
-- DELETE FROM CLIENTE WHERE id_cliente = 1;


-- ==========================================================================
-- PARTE 9: JSON
-- No MariaDB, JSON e um texto que o banco valida: JSON mal formado da erro.
-- ==========================================================================

-- 9.1 Configuracao da loja
CREATE TABLE CONFIGURACAO_LOJA (
    id_config INT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    dados     JSON NOT NULL
);

-- INSERT com JSON
INSERT INTO CONFIGURACAO_LOJA (nome, dados)
VALUES (
    'Informacoes da loja',
    '{"nome_fantasia": "Nakama Geek", "frete_gratis": true, "valor_minimo_frete": 120.00}'
);

-- SELECT com JSON_EXTRACT: pega um campo pelo caminho ($.campo)
SELECT nome,
       JSON_EXTRACT(dados, '$.nome_fantasia') AS nome_fantasia,
       JSON_EXTRACT(dados, '$.frete_gratis') AS frete_gratis,
       JSON_EXTRACT(dados, '$.valor_minimo_frete') AS valor_minimo_frete
FROM CONFIGURACAO_LOJA;

-- UPDATE com JSON_SET: altera um campo sem reescrever o JSON inteiro
UPDATE CONFIGURACAO_LOJA
SET dados = JSON_SET(dados, '$.valor_minimo_frete', 150.00)
WHERE id_config = 1;

SELECT nome,
       JSON_EXTRACT(dados, '$.valor_minimo_frete') AS valor_minimo_frete
FROM CONFIGURACAO_LOJA;


-- 9.2 Detalhes dos produtos (atributos diferentes para cada produto)
-- UNIQUE em id_produto: no maximo uma linha de detalhes por produto.
CREATE TABLE PRODUTO_DETALHES (
    id_detalhe INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT NOT NULL UNIQUE,
    atributos  JSON,

    CONSTRAINT fk_detalhes_produto FOREIGN KEY (id_produto)
        REFERENCES PRODUTO (id_produto)
);

INSERT INTO PRODUTO_DETALHES (id_produto, atributos)
VALUES
(1, '{"autor": "Masashi Kishimoto", "editora": "Panini", "paginas": 192}'),
(2, '{"autor": "Eiichiro Oda", "editora": "Panini", "paginas": 208}'),
(4, '{"altura_cm": 18, "material": "PVC", "articulado": true}'),
(7, '{"tamanhos": ["P", "M", "G"], "cor": "Preto", "material": "Algodão"}');

-- JSON_UNQUOTE tira as aspas do texto extraido
SELECT p.nome,
       JSON_EXTRACT(d.atributos, '$.autor') AS autor,
       JSON_UNQUOTE(JSON_EXTRACT(d.atributos, '$.editora')) AS editora
FROM PRODUTO_DETALHES d
INNER JOIN PRODUTO p
ON p.id_produto = d.id_produto;

-- Filtrar pelo valor dentro do JSON
SELECT p.nome
FROM PRODUTO_DETALHES d
INNER JOIN PRODUTO p
ON p.id_produto = d.id_produto
WHERE JSON_UNQUOTE(JSON_EXTRACT(d.atributos, '$.editora')) = 'Panini';

-- JSON_SET: altera um campo existente e acrescenta um novo
UPDATE PRODUTO_DETALHES
SET atributos = JSON_SET(atributos, '$.paginas', 200, '$.edicao', 'Primeira')
WHERE id_produto = 1;

SELECT id_produto, atributos
FROM PRODUTO_DETALHES
WHERE id_produto = 1;

-- Validar o JSON (1 = valido)
SELECT id_produto, JSON_VALID(atributos) AS valido
FROM PRODUTO_DETALHES;


-- ==========================================================================
-- PARTE 10: TRANSACOES (START TRANSACTION, COMMIT, ROLLBACK)
-- Rodar o script inteiro (Alt+X) mantem tudo na mesma conexao.
-- ==========================================================================

-- 10.1 ROLLBACK: desfaz a alteracao
START TRANSACTION;

UPDATE PRODUTO
SET estoque = 0
WHERE id_produto = 4;

-- dentro da transacao o estoque do Goku aparece como 0
SELECT id_produto, nome, estoque
FROM PRODUTO
WHERE id_produto = 4;

ROLLBACK;

-- depois do rollback o estoque volta ao valor original (15)
SELECT id_produto, nome, estoque
FROM PRODUTO
WHERE id_produto = 4;


-- 10.2 COMMIT em uma tabela temporaria
DROP TEMPORARY TABLE IF EXISTS TESTE_TRANSACAO;

CREATE TEMPORARY TABLE TESTE_TRANSACAO (
    id INT PRIMARY KEY,
    descricao VARCHAR(100)
) ENGINE=InnoDB;

START TRANSACTION;

INSERT INTO TESTE_TRANSACAO (id, descricao)
VALUES (1, 'Teste de transacao confirmado');

SELECT * FROM TESTE_TRANSACAO;

COMMIT;

SELECT * FROM TESTE_TRANSACAO;

DROP TEMPORARY TABLE TESTE_TRANSACAO;


-- 10.3 VENDA COMPLETA COM COMMIT
-- Pedido da Carla (cliente 3): cria pedido, item, baixa o estoque e registra
-- o pagamento. Ou tudo vale (COMMIT) ou nada vale (ROLLBACK).
START TRANSACTION;

INSERT INTO PEDIDO (id_cliente, status)
VALUES (3, 'pago');

-- LAST_INSERT_ID() devolve o id do pedido recem-criado
SET @novo_pedido = LAST_INSERT_ID();

INSERT INTO ITEM_PEDIDO (id_pedido, id_produto, quantidade, preco_unitario)
VALUES (@novo_pedido, 2, 1, 36.90);

UPDATE PRODUTO
SET estoque = estoque - 1
WHERE id_produto = 2;

INSERT INTO PAGAMENTO (id_pedido, forma_pagamento, valor, status, data_pagamento)
VALUES (@novo_pedido, 'Pix', 36.90, 'aprovado', NOW());

COMMIT;

-- Conferir a venda: pedido 11, estoque do produto 2 em 39, pagamento 10
SELECT * FROM PEDIDO ORDER BY id_pedido DESC LIMIT 1;
SELECT id_produto, nome, estoque FROM PRODUTO WHERE id_produto = 2;
SELECT * FROM PAGAMENTO ORDER BY id_pagamento DESC LIMIT 1;


-- ==========================================================================
-- PARTE 11: DROP
-- Operacoes irreversiveis: aqui so em objetos de teste.
-- ==========================================================================

-- DROP TABLE em uma tabela de teste
CREATE TABLE TABELA_TESTE_DROP (
    id INT PRIMARY KEY,
    descricao VARCHAR(100)
);

INSERT INTO TABELA_TESTE_DROP (id, descricao)
VALUES (1, 'Teste de exclusao de tabela');

SELECT * FROM TABELA_TESTE_DROP;

DROP TABLE TABELA_TESTE_DROP;


-- DROP DATABASE em um banco de teste (nunca no banco principal)
CREATE DATABASE IF NOT EXISTS nakama_geek_teste_drop;

USE nakama_geek_teste_drop;

CREATE TABLE teste (
    id INT PRIMARY KEY
);

DROP DATABASE nakama_geek_teste_drop;

-- Volta ao banco principal
USE nakama_geek;


-- TESTE DE INTEGRIDADE (erro esperado, rodar manualmente):
-- CATEGORIA e usada por PRODUTO, entao nao pode ser apagada.
-- DROP TABLE CATEGORIA;


-- ORDEM CORRETA PARA APAGAR TODO O PROJETO (so no fim, nunca antes de entregar):
-- primeiro as tabelas que dependem de outras, por ultimo as referenciadas.
-- DROP TABLE PRODUTO_DETALHES;
-- DROP TABLE CONFIGURACAO_LOJA;
-- DROP TABLE PAGAMENTO;
-- DROP TABLE ITEM_PEDIDO;
-- DROP TABLE PEDIDO;
-- DROP TABLE PRODUTO;
-- DROP TABLE CATEGORIA;
-- DROP TABLE CLIENTE;
-- DROP DATABASE nakama_geek;


-- ==========================================================================
-- CONFERENCIA FINAL. Esperado: 5, 10, 12, 11, 16, 10
-- ==========================================================================
SELECT 'CATEGORIA' AS tabela, COUNT(*) AS total FROM CATEGORIA
UNION ALL
SELECT 'CLIENTE', COUNT(*) FROM CLIENTE
UNION ALL
SELECT 'PRODUTO', COUNT(*) FROM PRODUTO
UNION ALL
SELECT 'PEDIDO', COUNT(*) FROM PEDIDO
UNION ALL
SELECT 'ITEM_PEDIDO', COUNT(*) FROM ITEM_PEDIDO
UNION ALL
SELECT 'PAGAMENTO', COUNT(*) FROM PAGAMENTO;

-- ==========================================================================
-- FIM DO PROJETO
-- ==========================================================================