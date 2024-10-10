-- Criar o banco de dados
CREATE DATABASE IF NOT EXISTS torneios_db;
USE torneios_db;

-- Tabela Modalidade (define se é individual ou por equipe)
CREATE TABLE Modalidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo ENUM('individual', 'equipe') NOT NULL
);

-- Tabela Atleta (somente para modalidades individuais)
CREATE TABLE Atleta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE,
    modalidade_id INT,
    FOREIGN KEY (modalidade_id) REFERENCES Modalidade(id)
);

-- Tabela Equipe (somente para modalidades em equipe)
CREATE TABLE Equipe (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    modalidade_id INT,
    FOREIGN KEY (modalidade_id) REFERENCES Modalidade(id)
);

-- Tabela Torneio
CREATE TABLE Torneio (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    formato ENUM('eliminatorias', 'pontos_corridos') NOT NULL,
    modalidade_id INT,
    FOREIGN KEY (modalidade_id) REFERENCES Modalidade(id)
);

-- Tabela Fase (classificatórias, oitavas, quartas, etc.)
CREATE TABLE Fase (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    torneio_id INT,
    tipo_fase ENUM('grupos', 'eliminatorias') NOT NULL,
    FOREIGN KEY (torneio_id) REFERENCES Torneio(id)
);

-- Tabela Grupo (apenas se houver fase de grupos)
CREATE TABLE Grupo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50),
    fase_id INT,
    FOREIGN KEY (fase_id) REFERENCES Fase(id)
);

-- Tabela Partida
CREATE TABLE Partida (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fase_id INT,
    data_hora DATETIME NOT NULL,
    local VARCHAR(100),
    equipe1_id INT,
    equipe2_id INT,
    pontuacao_equipe1 INT DEFAULT 0,
    pontuacao_equipe2 INT DEFAULT 0,
    resultado ENUM('vitoria_equipe1', 'vitoria_equipe2', 'empate'),
    FOREIGN KEY (fase_id) REFERENCES Fase(id),
    FOREIGN KEY (equipe1_id) REFERENCES Equipe(id),
    FOREIGN KEY (equipe2_id) REFERENCES Equipe(id)
);

-- Tabela Pontuacao (para armazenar as pontuações por equipe/atleta)
CREATE TABLE Pontuacao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    equipe_id INT,
    atleta_id INT,
    fase_id INT,
    pontos INT DEFAULT 0,
    FOREIGN KEY (equipe_id) REFERENCES Equipe(id),
    FOREIGN KEY (atleta_id) REFERENCES Atleta(id),
    FOREIGN KEY (fase_id) REFERENCES Fase(id)
);

