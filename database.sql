SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS referenciam;    -- Ordem inversa da criação
DROP TABLE IF EXISTS relatorios;
DROP TABLE IF EXISTS realiza;
DROP TABLE IF EXISTS incluem;
DROP TABLE IF EXISTS exames;
DROP TABLE IF EXISTS tipos;
DROP TABLE IF EXISTS visitam;
DROP TABLE IF EXISTS internados;
DROP TABLE IF EXISTS n_voluntarios;
DROP TABLE IF EXISTS voluntarios;
DROP TABLE IF EXISTS visitantes;
DROP TABLE IF EXISTS utentes;
DROP TABLE IF EXISTS n_empregados;
DROP TABLE IF EXISTS dirigentes;
DROP TABLE IF EXISTS inicio;
DROP TABLE IF EXISTS especialidades;
DROP TABLE IF EXISTS tecnicos;
DROP TABLE IF EXISTS medicos;
DROP TABLE IF EXISTS empregados;
DROP TABLE IF EXISTS camas;
DROP TABLE IF EXISTS exames_sala;
DROP TABLE IF EXISTS internamentos;
DROP TABLE IF EXISTS salas;
DROP TABLE IF EXISTS horario;
DROP TABLE IF EXISTS clinica;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE clinica(
  nome                        VARCHAR(40),
  data_de_inauguracao         DATE         NOT NULL,
  nipc                        NUMERIC(3)   NOT NULL,
  morada                      VARCHAR(40)  NOT NULL,
  telefone                    NUMERIC(9)   NOT NULL,
  correio_eletronico          VARCHAR(40)  NOT NULL,
  duracao_do_mandato          NUMERIC(5)   NOT NULL,
-- ========
    CONSTRAINT	pk_clininca
		PRIMARY KEY (nome),
-- ========
    CONSTRAINT un_clinica_nipc
        UNIQUE (nipc),
-- ========
    CONSTRAINT un_clinica_telefone
        UNIQUE (telefone),
-- ========
    CONSTRAINT un_clinica_correio_eletronico
        UNIQUE (correio_eletronico),
-- ========
    CONSTRAINT ck_clinica_duracao_do_mandato
        CHECK (duracao_do_mandato > 0) 
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE horario(
  dia_da_semana             VARCHAR(13),
  nome                      VARCHAR(40),
  visita                    TIME,
  funcionamento_nao_urgente TIME,

-- ========
    CONSTRAINT pk_horario
        PRIMARY KEY (nome, dia_da_semana),
-- ========
    CONSTRAINT fk_horario_nome
        FOREIGN KEY (nome)
            REFERENCES clinica (nome) ON DELETE CASCADE
);
 

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE salas(
  piso                    NUMERIC(2),
  sala             NUMERIC(3),
  nome                    VARCHAR(40),
  tipo_de_equipamento     VARCHAR(40),          -- uma sala pode não ter equipamentos
  numero_maximo_de_exames NUMERIC(2) NOT NULL,  -- uma sala pode não servir para fazer exames se equipamentos para esse efeito mas o valor 0 não é igual ao valor NULL
-- ========
    CONSTRAINT pk_salas
        PRIMARY KEY (nome, piso, sala),
-- ========
    CONSTRAINT fk_salas_nome   
        FOREIGN KEY (nome)
            REFERENCES clinica (nome) ON DELETE CASCADE,
-- ========
    CONSTRAINT ck_salas_numero_maximo_de_exames
        CHECK (numero_maximo_de_exames >= 0) 
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE internamentos(
  piso            NUMERIC(2),
  sala            NUMERIC(3),
  nome            VARCHAR(40),
  tipo            VARCHAR(40) NOT NULL,
  max_camas       NUMERIC(3)  NOT NULL,
-- ========
    CONSTRAINT pk_internamentos
        PRIMARY KEY (nome, piso, sala),
-- ========
    CONSTRAINT fk_internamentos_nome   
        FOREIGN KEY (nome,piso,sala)
            REFERENCES salas (nome,piso,sala) ON DELETE CASCADE,
-- ========
    CONSTRAINT ck_internamentos_max_camas
        CHECK (max_camas >= 0),
-- ========
    CONSTRAINT ck_internamentos_tipo
        CHECK ((tipo = "enfermaria") OR (tipo = "quarto"))   
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE exames_sala(
  piso            NUMERIC(2),
  sala            NUMERIC(3),
  nome            VARCHAR(40),
-- ========
    CONSTRAINT pk_exames
        PRIMARY KEY (nome, piso, sala),
-- ========
    CONSTRAINT fk_exames_nome   
        FOREIGN KEY (nome,piso,sala)
            REFERENCES salas (nome,piso,sala) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE camas(
    nome                VARCHAR(40),
    sala                NUMERIC(3),
    piso                NUMERIC(2),
    numero_da_cama      NUMERIC(3), 

-- ========
    CONSTRAINT pk_camas
        PRIMARY KEY (nome, piso, sala ,numero_da_cama),
-- ========
    CONSTRAINT fk_camas_nome
        FOREIGN KEY (nome,piso,sala) 
          REFERENCES internamentos (nome,piso,sala) ON DELETE CASCADE
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE empregados(
  NIF	NUMERIC(9),
  NIC	NUMERIC(9) NOT NULL,
  nome	VARCHAR(40) NOT NULL,
  morada	VARCHAR(40) NOT NULL,
  genero	VARCHAR(40) NOT NULL,
  email	VARCHAR(40) NOT NULL,
  telefone NUMERIC(9) NOT NULL,
  data_de_nascimento	DATE NOT NULL,
-- ========
	CONSTRAINT pk_empregados
		PRIMARY KEY (NIF)
);


-- ---------------------------------------------------------------------------------------------------------------------

CREATE TABLE medicos(
  NIF	NUMERIC(9),
-- ========
 	CONSTRAINT pk_medicos
		PRIMARY KEY (NIF),
-- ========
	CONSTRAINT fk_medicos_NIF
		FOREIGN KEY (NIF) REFERENCES empregados (NIF)
);
-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE tecnicos(
  NIF	NUMERIC(9),
  data	DATE NOT NULL,
-- ========
 	CONSTRAINT pk_tecnicos
		PRIMARY KEY (NIF),
-- ========
	CONSTRAINT fk_tecnicos_NIF
		FOREIGN KEY (NIF) REFERENCES empregados (NIF)
);


-- ---------------------------------------------------------------------------------------------------------------------

CREATE TABLE especialidades(
  sigla	VARCHAR(5),
  nome	VARCHAR(40) NOT NULL,
  preco_diario_internamento  NUMERIC(7,2) NOT NULL,
-- ========
	CONSTRAINT pk_especialidades
		PRIMARY KEY (sigla),
-- ========
	CONSTRAINT ck_especialidades_preco_diario_internamento
		CHECK (preco_diario_internamento > 0)
 
);


-- ---------------------------------------------------------------------------------------------------------------------

CREATE TABLE inicio(
  sigla	VARCHAR(5),
  NIF	NUMERIC(9),
  data_de_inicio  DATE NOT NULL,
-- ========
	CONSTRAINT pk_inicio
		PRIMARY KEY (sigla,NIF),
-- ========
	CONSTRAINT fk_inicio_medicos
		FOREIGN KEY (NIF) REFERENCES medicos (NIF),
-- ========
	CONSTRAINT fk_inicio_especialidades
		FOREIGN KEY (sigla) REFERENCES especialidades (sigla)
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE dirigentes(
  NIF	NUMERIC(9),
  nome  VARCHAR(40),
  data_de_inicio  DATE NOT NULL,
-- ========
	CONSTRAINT pk_inicio
		PRIMARY KEY (NIF,nome),
-- ========
	CONSTRAINT fk_dirigentes_NIF
		FOREIGN KEY (NIF) REFERENCES medicos (NIF),
-- ========
	CONSTRAINT fk_dirigentes_nome
		FOREIGN KEY (nome) REFERENCES clinica (nome)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE n_empregados(
	nif             NUMERIC(9),
    nic             NUMERIC(9)  NOT NULL,
    nome            VARCHAR(40) NOT NULL,
    data_nascimento NUMERIC(10) NOT NULL,
    genero          VARCHAR(10) NOT NULL,
    morada          VARCHAR(40) NOT NULL,
    telefone        VARCHAR(13) NOT NULL,
    email           VARCHAR(40) NOT NULL,
    clinica         VARCHAR(40),

-- ========
    CONSTRAINT pk_nif 
        PRIMARY KEY(nif),
-- ========
    CONSTRAINT un_nome_utente 
        UNIQUE(nome),
-- ========
    CONSTRAINT fk_n_empregados
        FOREIGN KEY (clinica) REFERENCES clinica (nome)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE utentes(
    nif NUMERIC(9),

-- ========
    CONSTRAINT pk_utentes
        PRIMARY KEY(nif),
-- ========
    CONSTRAINT fk_utentes_nif
        FOREIGN KEY (nif) REFERENCES n_empregados (nif) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE visitantes(
    nif NUMERIC(9),

-- ========
    CONSTRAINT pk_visitantes
        PRIMARY KEY(nif),
-- ========
    CONSTRAINT fk_visitantes_nif
        FOREIGN KEY (nif) REFERENCES n_empregados (nif) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE voluntarios(
    nif                  NUMERIC(9),
	numero_visitas       NUMERIC(4) NOT NULL,
    associacao_solidaria VARCHAR(40) NOT NULL,

-- ========
    CONSTRAINT pk_voluntarios
        PRIMARY KEY(nif),
-- ========
    CONSTRAINT fk_voluntarios_nif
        FOREIGN KEY (nif) REFERENCES visitantes (nif) ON DELETE CASCADE,
-- ========
    CONSTRAINT ck_voluntarios_numero_visitas
        CHECK (numero_visitas >= 0)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE n_voluntarios(
    nif NUMERIC(9),

-- ========
    CONSTRAINT pk_n_voluntarios
        PRIMARY KEY(nif),
-- ========
    CONSTRAINT fk_n_voluntarios_nif
        FOREIGN KEY (nif) REFERENCES visitantes (nif) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE internados(
    cama                NUMERIC(3),
    nif                 NUMERIC(9),
	max_n_visitantes    NUMERIC(10) NOT NULL,
    inicio_internamento DATETIME    NOT NULL,
    responsavel         NUMERIC(9),

-- ========
    CONSTRAINT pk_internados 
        PRIMARY KEY (nif,cama),
-- ========
    CONSTRAINT fk_internados_nif
        FOREIGN KEY (nif) REFERENCES utentes (nif) ON DELETE CASCADE,
-- ========
    CONSTRAINT fk_internados_responsavel
        FOREIGN KEY (responsavel) REFERENCES medicos (NIF) ON DELETE CASCADE
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE visitam (
    numero		  NUMERIC(3),
    nif_vis       NUMERIC(9),
    nif_int       NUMERIC(9),
    caracter      VARCHAR(40) NOT NULL,
    inicio        DATETIME    NOT NULL,
    fim           DATETIME    NOT NULL,

-- ========
    CONSTRAINT pk_visitam
        PRIMARY KEY (nif_vis,nif_int,numero),
-- ========
    CONSTRAINT fk_visitam_nif_vis
        FOREIGN KEY (nif_vis) REFERENCES visitantes (nif) ON DELETE CASCADE,
-- ========
    CONSTRAINT fk_visitam_nif_int
        FOREIGN KEY (nif_int) REFERENCES internados (nif) ON DELETE CASCADE
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE tipos(
	sigla			VARCHAR(5),
	tipo			VARCHAR(40)		NOT NULL,
	preco_normal	NUMERIC(3,2)	NOT NULL,
	preco_urgencia	NUMERIC(3,2)	NOT NULL,
-- ========
	CONSTRAINT	pk_tipos_exame 
		PRIMARY KEY (sigla),
-- ========
	CONSTRAINT	un_tipos_exame_tipo				-- chave candidata: NOT NULL + UNIQUE
		UNIQUE (tipo),
-- ========
	CONSTRAINT ck_tipos_exame_preco_normal		-- RIA 14
		CHECK (preco_normal > 0.0),
-- ========
	CONSTRAINT ck_tipos_exame_preco_urgencia	-- RIA 14
    	CHECK (preco_urgencia > 0.0)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE exames(
	codigo				NUMERIC(5),
	nif_responsavel		NUMERIC(9)		NOT NULL,
	nif_tecnico			NUMERIC(9)		NOT NULL,
	data_inicio			DATE			NOT NULL,
	data_fim			DATE			NOT NULL,
  sigla				VARCHAR(5),
	tipo				VARCHAR(40),
	clinica				VARCHAR(40),
-- ========
	CONSTRAINT pk_exames
		PRIMARY KEY (codigo),
-- ========
	CONSTRAINT	fk_exames_empregados_med
		FOREIGN KEY (nif_responsavel)
		REFERENCES medicos (NIF),
-- ========
	CONSTRAINT	fk_exames_clinica
		FOREIGN KEY (clinica)
		REFERENCES clinica (nome),
-- ========
    CONSTRAINT fk_exames_sigla
    	FOREIGN KEY (sigla)
    		REFERENCES tipos(sigla),
-- ========
	CONSTRAINT	ck_exames_data_fim				-- Data do fim tem de ser posterior ao início
		CHECK (data_fim > data_inicio)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE incluem(
	sigla VARCHAR(5),
	codigo NUMERIC(5),
-- ========
	CONSTRAINT pk_incluem
		PRIMARY KEY (sigla,codigo),
-- ========
	CONSTRAINT fk_incluem_sigla
		FOREIGN KEY (sigla) REFERENCES tipos (sigla),
-- ========
	CONSTRAINT fk_incluem_codigo
		FOREIGN KEY (codigo) REFERENCES exames (codigo)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE realiza(
	nif		NUMERIC(9),
	codigo	NUMERIC(5),
	sigla	VARCHAR(5),
-- ========
	CONSTRAINT	pk_realiza
		PRIMARY KEY (nif, codigo, sigla),
-- ========
	CONSTRAINT	fk_realiza_empregados
		FOREIGN KEY (nif)
		REFERENCES tecnicos (nif),
-- ========
	CONSTRAINT	fk_realiza_exames
		FOREIGN KEY (sigla,codigo)
		REFERENCES incluem (sigla,codigo)
);


-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE relatorios(
	codigo				NUMERIC(5),
	numero_sequencial	NUMERIC(5),
	id					NUMERIC(5),
	nif_responsavel		NUMERIC(9)		NOT NULL,
	parecer				VARCHAR(100)	NOT NULL,
	descricao			VARCHAR(100)	NOT NULL,
	dia					DATE			NOT NULL,
-- ========
	CONSTRAINT	pk_relatorios
		PRIMARY KEY (codigo, numero_sequencial),
-- ========
	CONSTRAINT	fk_relatorios_exames
		FOREIGN KEY (codigo)
		REFERENCES exames (codigo) ON DELETE CASCADE,
-- ========
	CONSTRAINT un_relatorios_id
		UNIQUE(id),
-- ========
	CONSTRAINT	fk_relatorios_empregados
		FOREIGN KEY (nif_responsavel)
		REFERENCES medicos (NIF)
);

-- ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE referenciam (
	id_referenciador 		NUMERIC(5),
	id_referenciado     	NUMERIC(5),
-- ========
	CONSTRAINT	pk_referenciam
	PRIMARY KEY (id_referenciador,id_referenciado),
-- ========
	CONSTRAINT	fk_referenciam_id_referenciador
		FOREIGN KEY (id_referenciador) 
			REFERENCES relatorios (id),
-- ========
	CONSTRAINT	fk_referenciam_id_referenciado
		FOREIGN KEY (id_referenciado) 
			REFERENCES relatorios (id),
-- ========
	CONSTRAINT	ck_referenciam_id_referenciador
		CHECK(id_referenciador <> id_referenciado)
);
-- ---------------------------------------------------------------------------------------------------------------------
ALTER TABLE medicos ADD (
  supervisionador VARCHAR(5),
  especialidade_atual	VARCHAR(5) NOT NULL,
-- ========
	CONSTRAINT fk_medicos_supervisionador
		FOREIGN KEY (supervisionador) REFERENCES especialidades (sigla),
-- ========
	CONSTRAINT un_medicos_supervisionador
		UNIQUE (supervisionador),
-- ========
	CONSTRAINT fk_medicos_especialidade_atual
		FOREIGN KEY (especialidade_atual) REFERENCES especialidades (sigla)
);

-- ---------------------------------------------------------------------------------------------------------------------
ALTER TABLE empregados ADD(
  clinica VARCHAR(40),
-- ========
	CONSTRAINT fk_empregados_clinica
		FOREIGN KEY (clinica) REFERENCES clinica (nome)
);
-- ---------------------------------------------------------------------------------------------------------------------
ALTER TABLE internados ADD(
  sigla VARCHAR(5) NOT NULL,
  medico_responsavel NUMERIC(9) NOT NULL,
-- ========
	CONSTRAINT fk_internado_sigla
		FOREIGN KEY (sigla) REFERENCES especialidades (sigla),
-- ========
	CONSTRAINT fk_internado_medico_responsavel
		FOREIGN KEY (medico_responsavel) REFERENCES medicos (NIF),
-- ========
	CONSTRAINT un_internado_sigla
		UNIQUE (sigla),
-- ========
	CONSTRAINT un_internado_medico_responsavel
		UNIQUE (medico_responsavel)
);

-- ---------------------------------------------------------------------------------------------------------------------
-- RIA não suportadas
-- ---------------------------------------------------------------------------------------------------------------------

-- RIA1: o médico encarregado do internado tem de ter a mesma especialidade do internado
-- RIA2: O médico responsável pelo exame tem que estar na mesma clinica do que o técnico que produz o exame
-- RIA4: Os visitantes que visitam os internados têm que estar na mesma clinica que os internados 
-- RIA6: A cama dos internados tem que existir nas salas dos internamentos. Além disso têm que estar na mesma clínica que os internados
-- RIA9: O médico que dirige a clinica tem de ser um empregado desta mesma
-- RIA10: O médico que supervisionam as especialidades têm ter ter a mesma especialidade que estão a supervisionar
-- RIA11: Os médicos que supervisionam as especialidades têm de trabalhar na mesma clinicas em que supervisionam
-- RIA12: Os técnicos que realizam os exames têm de estar habilitados a realizar o exame com o correspondente tipo de exame
-- RIA13: O medico responsável do exame tem de ser o mesmo do que o médico responsável pelo internado



-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS
-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS clinica
INSERT INTO clinica (nome,data_de_inauguracao,NIPC,morada,telefone,correio_eletronico,duracao_do_mandato)
	VALUE('ola','2000-08-21',321,'rua ali do canto',927578823,'olá@funcionasff.com', 365);

INSERT INTO clinica (nome,data_de_inauguracao,NIPC,morada,telefone,correio_eletronico,duracao_do_mandato)
	VALUE('adeus','2002-08-21',488,'rua aqui do canto',916837046,'adeus@funcionasff.com',233);

INSERT INTO clinica (nome,data_de_inauguracao,NIPC,morada,telefone,correio_eletronico,duracao_do_mandato)
	VALUE('ate ja','2002-08-22',322,'rua ali do canto',927578824,'ate_ja@funcionasff.com', 234);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS empregados
INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(123456789,987654321,'duarte miranda','rua do beco','masculino',912345678,'abcd@abcd.com','2003-12-02','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(111111111,987654321,'renato pereira','rua de casa','outro',919999999,'abcde@abcd.com','1990-01-01','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(111111112,987654321,'duarte fernandes','rua da faculdade','masculino',918888888,'abcdef@abcd.com','1990-01-02','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(111111113,987654321,'beatriz pereira','rua do outro lado','feminino',917777777,'abcdefg@abcd.com','1990-01-03','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(111111114,987655555,'ana cacho paulo','rua do outro lado','feminino',916666666,'abcdefge@abcd.com','2000-01-03','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(121111111,983647215,'ana jagunco','rua do atrás','feminino',9122354846,'abcdefgh@abcd.com','1970-06-13','ola');

INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(121111112,983747316,'tiago josé','rua da esquina','feminino',921221121,'abcdefghi@abcd.com','1989-10-01','ola');
    
INSERT INTO empregados (NIF,NIC,nome,morada,genero,telefone,email,data_de_nascimento,clinica)
	VALUE(121111113,984648226,'ana jagunco','rua do lá do fundo','feminino',9122354846,'abcdefghij@abcd.com','1970-08-23','ate ja');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS tecnicos
INSERT INTO tecnicos (NIF, data) 
	VALUES(123456789,'2020-01-02');

INSERT INTO tecnicos (NIF, data) 
	VALUES(121111111,'2010-06-15');
    
INSERT INTO tecnicos (NIF, data) 
	VALUES(121111112,'2001-10-30');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS especialidades
INSERT INTO especialidades (sigla,nome,preco_diario_internamento)
	VALUES('D', 'dermatology', 100);

INSERT INTO especialidades (sigla,nome,preco_diario_internamento)
	VALUES('FM', 'family medicine', 50);

INSERT INTO especialidades (sigla,nome,preco_diario_internamento)
	VALUES('N', 'Neurology', 50);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS medicos
INSERT INTO medicos(NIF,especialidade_atual)
	VALUES(111111111,'D');

INSERT INTO medicos(NIF,especialidade_atual,supervisionador)
	VALUES(111111112,'D','FM');

INSERT INTO medicos(NIF,especialidade_atual)
	VALUES(111111113,'N');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS dirigentes
INSERT INTO dirigentes (NIF,nome,data_de_inicio)
	VALUES(111111113,'ola','2020-01-01');

INSERT INTO dirigentes (NIF,nome,data_de_inicio)
	VALUES(111111111,'ola','2019-01-01');
    
INSERT INTO dirigentes (NIF,nome,data_de_inicio)
	VALUES(111111112,'ola','2018-01-01');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS inicio
INSERT INTO inicio (NIF,sigla,data_de_inicio)
	VALUES(111111111,'D',2022-11-30);

INSERT INTO inicio (NIF,sigla,data_de_inicio)
	VALUES(111111111,'N',2022-11-30);

INSERT INTO inicio (NIF,sigla,data_de_inicio)
	VALUES(111111112,'D',2020-10-15);

INSERT INTO inicio (NIF,sigla,data_de_inicio)
	VALUES(111111112,'FM',2021-9-10);

INSERT INTO inicio (NIF,sigla,data_de_inicio)
	VALUES(111111113,'D',2019-03-30);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS horario
INSERT INTO horario (dia_da_semana,nome,visita)
	VALUES('segunda','ola','08-00-00');

INSERT INTO horario (dia_da_semana,nome,visita,funcionamento_nao_urgente)
	VALUES('terça','ola', '08-00-00','14-30-00');

INSERT INTO horario (dia_da_semana,nome,visita,funcionamento_nao_urgente)
	VALUES('quarta','adeus', '10-20-00','16-45-00');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS salas
INSERT INTO salas (nome,piso,sala,tipo_de_equipamento,numero_maximo_de_exames)
	VALUES ('ola',3,24,'cirurgico',12);

INSERT INTO salas (nome,piso,sala,tipo_de_equipamento,numero_maximo_de_exames)
	VALUES ('ola',2,17,'básico',0);

INSERT INTO salas (nome,piso,sala,tipo_de_equipamento,numero_maximo_de_exames)
	VALUES ('adeus',2,16,'cirugico',1);
    
INSERT INTO salas (nome,piso,sala,tipo_de_equipamento,numero_maximo_de_exames)
	VALUES ('ate ja',1,23,'raioX',4);

INSERT INTO salas (nome,piso,sala,numero_maximo_de_exames)
	VALUES ('ate ja',1,10,4);
-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS internamentos
INSERT INTO internamentos (nome,piso,sala,tipo,max_camas)
	VALUES ('ola',3,24,'enfermaria',7);

INSERT INTO internamentos (nome,piso,sala,tipo,max_camas)
	VALUES ('ola',2,17,'quarto',11);

INSERT INTO internamentos (nome,piso,sala,tipo,max_camas)
	VALUES ('ate ja',1,10,'quarto',11);
-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS exames_sala
INSERT INTO exames_sala (nome,piso,sala)
	VALUES ('ola',2,17);

INSERT INTO exames_sala (nome,piso,sala)
	VALUES ('ate ja',1,23);

INSERT INTO exames_sala (nome,piso,sala)
	VALUES ('adeus',2,16);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS camas
INSERT INTO camas(nome,piso,sala,numero_da_cama)
	VALUES ('ola',3,24,4);

INSERT INTO camas(nome,piso,sala,numero_da_cama)
	VALUES ('ola',3,24,1);

INSERT INTO camas(nome,piso,sala,numero_da_cama)
	VALUES ('ola',2,17,3);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS n_empregados
INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999999,99999999,'alberto jacinto','2001-01-01','masculino','ali ao lado',963369693,'alj@123.com','ola');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999998,99999998,'alberto joão','2001-01-01','masculino','ali ao lado',963369692,'aljo@123.com','ola');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999997,99999997,'joão joão','2001-01-01','masculino','ali ao lado',963369691,'jojo@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999992,99999992,'eva gina','2001-01-01','masculino','ali ao lado',963369686,'evagina@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999993,99999993,'adolfo dias','2001-01-01','masculino','ali ao lado',963369687,'adolfodias@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999994,99999994,'jacinto pinto','2001-01-01','masculino','ali ao lado',963369688,'jacintopinto@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999995,99999995,'isaac abrão ','2001-01-01','masculino','ali ao lado',963369689,'isaacabrão@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999996,99999996,'tony tony','2001-01-01','masculino','ali ao lado',963369690,'toto@123.com','adeus');

INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999991,99999991,'amilcar dias','1992-12-20','masculino','deste ao lado',910873901,'amilcardias@123.com','ola');
    
INSERT INTO n_empregados (nif,nic,nome,data_nascimento,genero,morada,telefone,email,clinica)
	VALUES (999999990,99999990,'jose joao','1979-05-10','masculino','para o lado',953792691,'josejoao@123.com','ola');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS utentes
INSERT INTO utentes (nif)
	VALUES (999999999);

INSERT INTO utentes (nif)
	VALUES (999999992);
    
INSERT INTO utentes (nif)
	VALUES (999999993);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS visitantes
INSERT INTO visitantes (nif)
	VALUES (999999997);

INSERT INTO visitantes (nif)
	VALUES (999999998);

INSERT INTO visitantes (nif)
	VALUES (999999996);
    
INSERT INTO visitantes (nif)
	VALUES (999999995);

INSERT INTO visitantes (nif)
	VALUES (999999991);
    
INSERT INTO visitantes (nif)
	VALUES (999999990);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS voluntarios
INSERT INTO voluntarios (nif,numero_visitas,associacao_solidaria)
	VALUES (999999998,2,'nem sei o que é que isso é');

INSERT INTO voluntarios (nif,numero_visitas,associacao_solidaria)
	VALUES (999999991,3,'nem sei o que é que isso é');
    
INSERT INTO voluntarios (nif,numero_visitas,associacao_solidaria)
	VALUES (999999990,7,'para os pobres');

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS n_voluntarios
INSERT INTO n_voluntarios (nif)
	VALUES (999999997);

INSERT INTO n_voluntarios (nif)
	VALUES (999999996);
    
INSERT INTO n_voluntarios (nif)
	VALUES (999999995);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS internados
INSERT INTO internados (cama,nif,sigla,max_n_visitantes,inicio_internamento,medico_responsavel)
	VALUES (1,999999999,'D',8,'2022-01-01 12-00-00',111111111);

INSERT INTO internados (cama,nif,sigla,max_n_visitantes,inicio_internamento,medico_responsavel)
	VALUES (4,999999992,'FM',3,'2021-06-10 16-41-00',111111112);

INSERT INTO internados (cama,nif,sigla,max_n_visitantes,inicio_internamento,medico_responsavel)
	VALUES (3,999999993,'N',2,'2020-10-21 08-30-00',111111113);

-- ---------------------------------------------------------------------------------------------------------------------
-- INSERTS visitam
INSERT INTO visitam (numero,nif_vis,nif_int,caracter,inicio,fim)
	VALUES (001,999999998,999999999,'aniversario','2022-01-01 12-00-00','2022-01-01 12-30-00');

INSERT INTO visitam (numero,nif_vis,nif_int,caracter,inicio,fim)
	VALUES (002,999999997,999999992,'companhia','2022-01-01 08-45-00','2022-01-01 12-00-00');
    
INSERT INTO visitam (numero,nif_vis,nif_int,caracter,inicio,fim)
	VALUES (003,999999991,999999993,'trabalho','2022-01-01 12-00-00','2022-01-01 20-26-00');

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS tipos
INSERT INTO tipos(sigla,tipo,preco_normal,preco_urgencia)
	VALUES ('GT','Genetic Testing',500.69,600.29);

INSERT INTO tipos(sigla,tipo,preco_normal,preco_urgencia)
	VALUES ('GFA','Gastric Fuild Analysis',100.09,120.90);

INSERT INTO tipos(sigla,tipo,preco_normal,preco_urgencia)
	VALUES ('LP','Lumbar Puncture',230.09,257.90);

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS exames
INSERT INTO exames (codigo,nif_responsavel,data_inicio,data_fim,clinica)
	VALUES (59849,111111111,'2007-09-15 17-32-00','2007-09-15 20-00-00','ola');

INSERT INTO exames (codigo,nif_responsavel,data_inicio,data_fim,clinica)
	VALUES (71349,111111111,'2022-03-11 17-32-00','2022-05-10 20-00-00','ola');

INSERT INTO exames (codigo,nif_responsavel,data_inicio,data_fim,clinica)
	VALUES (04961,111111112,'2022-03-11 10-31-30','2022-05-10 22-15-20','ola');

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS incluem
INSERT INTO incluem (sigla,codigo)
	VALUES ('GFA', 59849);
    
INSERT INTO incluem (sigla,codigo)
	VALUES ('GT',71349);
    
INSERT INTO incluem (sigla,codigo)
	VALUES ('LP',04961);

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS realiza
INSERT INTO realiza (nif,codigo,sigla)
	VALUES (123456789,59849,'GFA');

INSERT INTO realiza (nif,codigo,sigla)
	VALUES (123456789,71349,'GT');
    
INSERT INTO realiza (nif,codigo,sigla)
	VALUES (123456789,04961,'LP');

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS relatorios
INSERT INTO relatorios(codigo,descricao,dia,id,nif_responsavel,numero_sequencial,parecer)
	VALUES(59849,'não sei','2007-09-15 17-32-00',00001,111111111,00001,'nada');
    
INSERT INTO relatorios(codigo,descricao,dia,id,nif_responsavel,numero_sequencial,parecer)
	VALUES(71349,'nada a descrever','2022-03-11 17-32-00',00002,111111111,00002,'nada');
    
INSERT INTO relatorios(codigo,descricao,dia,id,nif_responsavel,numero_sequencial,parecer)
	VALUES(04961,'grave problema mental','2022-03-11 10-31-30',00003,111111112,00003,'perigoso para a sociedade');

-- ----------------------------------------------------------------------------------------------------------------------
-- INSERTS referenciam
INSERT INTO referenciam(id_referenciador,id_referenciado)
	VALUES(00001,00002);
    
INSERT INTO referenciam(id_referenciador,id_referenciado)
	VALUES(00001,00003);
    
INSERT INTO referenciam(id_referenciador,id_referenciado)
	VALUES(00002,00003);
