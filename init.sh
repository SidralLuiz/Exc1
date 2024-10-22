#!/bin/bash

echo "iniciando os trabalhos"

sudo apt -y update || exit 1 

lista=("apache2" "mysql-server" "php-cli" "php-curl" "php-zip" "php-xml" "php-mbstring" "php" "libapache2-mod-php" "php-mysql")

instalar() {
    erro=0 
    sudo apt -y install $1 || erro=1
    if [ $erro -eq 1 ]; then
        echo "Deu erro ao instalar $1 ..."
    fi
}

for x in "${lista[@]}"; do
    instalar $x
done  # Aqui fechamos o loop for

# Verificar e criar a pasta 'database'
if [ -d "database" ]; then
    echo "A pasta 'database' existe. Apagando a pasta..."
    sudo rm -rf database  # Remove a pasta e seu conteúdo
fi
echo "Criando a pasta 'database' e o arquivo 'database.sh'..."

sudo mkdir -p database
cd database

# Criar o arquivo database.sh
sudo touch database.sh

# Escrever o conteúdo do script no arquivo
cat << 'EOF' > database.sh
#!/bin/bash
DB_NAME="luiz_sidral"
TABLE_NAME="sidral_carros"
MYSQL_ROOT_USER="root"
MYSQL="sudo mysql -u$MYSQL_ROOT_USER"
# Drop do banco de dados, caso exista
$MYSQL <<SQL
DROP DATABASE IF EXISTS $DB_NAME;
SQL
# Criação do banco de dados e da tabela
$MYSQL <<SQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;
CREATE TABLE $TABLE_NAME (
    modelo varchar(37),
    ano int,
    cor varchar(37),
    valor_mercado double
);
SQL
# Criação do usuário e concessão de privilégios
$MYSQL <<SQL
CREATE USER IF NOT EXISTS 'aluno'@'localhost' IDENTIFIED BY 'luiz';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'aluno'@'%';
FLUSH PRIVILEGES;
SQL
# Inserção de dados na tabela
$MYSQL <<SQL
USE $DB_NAME;
INSERT INTO $TABLE_NAME VALUES ("BMW", 1987, "Azul", 22500);
INSERT INTO $TABLE_NAME VALUES ("Audi", 1943, "Verde", 16000);
INSERT INTO $TABLE_NAME VALUES ("Ford", 1922, "Vermelho", 11000);
INSERT INTO $TABLE_NAME VALUES ("Chevrolet", 1930, "Cinza", 12000);
INSERT INTO $TABLE_NAME VALUES ("Mercedes", 1965, "Preto", 13000);
INSERT INTO $TABLE_NAME VALUES ("Volkswagen", 1800, "Amarelo", 14000);
INSERT INTO $TABLE_NAME VALUES ("Ford", 1995, "Vermelho", 18000);
INSERT INTO $TABLE_NAME VALUES ("Chevrolet", 2010, "Prata", 36000);
INSERT INTO $TABLE_NAME VALUES ("Honda", 2018, "Preto", 47000);
INSERT INTO $TABLE_NAME VALUES ("Toyota", 2008, "Branco", 29000);
INSERT INTO $TABLE_NAME VALUES ("Nissan", 2020, "Azul", 52000);
INSERT INTO $TABLE_NAME VALUES ("Audi", 2015, "Cinza", 43000);
INSERT INTO $TABLE_NAME VALUES ("Mercedes", 2005, "Verde", 34000);
INSERT INTO $TABLE_NAME VALUES ("Volkswagen", 1999, "Amarelo", 17500);
INSERT INTO $TABLE_NAME VALUES ("Fiat", 2012, "Laranja", 22000);
INSERT INTO $TABLE_NAME VALUES ("Jeep", 2021, "Preto", 62000);
INSERT INTO $TABLE_NAME VALUES ("Hyundai", 2017, "Prata", 33500);
INSERT INTO $TABLE_NAME VALUES ("Peugeot", 2013, "Azul", 25000);
INSERT INTO $TABLE_NAME VALUES ("Renault", 2006, "Vermelho", 20000);
INSERT INTO $TABLE_NAME VALUES ("Citroen", 2014, "Branco", 28000);
INSERT INTO $TABLE_NAME VALUES ("Mazda", 2019, "Verde", 54000);
INSERT INTO $TABLE_NAME VALUES ("Subaru", 2016, "Cinza", 40000);
INSERT INTO $TABLE_NAME VALUES ("Mitsubishi", 2004, "Preto", 26000);
INSERT INTO $TABLE_NAME VALUES ("Volvo", 2011, "Prata", 32000);
INSERT INTO $TABLE_NAME VALUES ("Jaguar", 2019, "Vermelho", 69000);
INSERT INTO $TABLE_NAME VALUES ("Porsche", 2022, "Azul", 125000);
INSERT INTO $TABLE_NAME VALUES ("Tesla", 2020, "Branco", 88000);
INSERT INTO $TABLE_NAME VALUES ("Kia", 2017, "Laranja", 30000);
INSERT INTO $TABLE_NAME VALUES ("Land Rover", 2015, "Verde", 57000);
SQL
# Exibir sucesso e listar os dados inseridos
echo "Sucesso"
$MYSQL <<SQL
USE $DB_NAME;
SELECT * FROM $TABLE_NAME;
SQL
EOF

# Criar a pasta 'php' e o arquivo 'index.php'
if [ -d "php" ]; then
    echo "A pasta 'php' existe. Apagando a pasta..."
    sudo rm -rf php  # Remove a pasta e seu conteúdo
fi

echo "Criando a pasta 'php' e o arquivo 'index.php'..."
cd ..
sudo mkdir -p php
cd php

# Criar o arquivo index.php com permissões apropriadas
sudo touch index.php

# Escrever o conteúdo do arquivo index.php
echo "<?php
  \$config = parse_ini_file('/var/www/html/.config2');
  // Conexão com o banco de dados
  \$conn = new mysqli(\$config['host'], \$config['user'], \$config['password'], \$config['dbname']);
  if (\$conn->connect_error) {
      die('Falha na conexão: ' . \$conn->connect_error);
  }
  // Consulta SQL para obter os dados da tabela sidral_carros
  \$sql = 'SELECT * FROM sidral_carros';
  \$result = \$conn->query(\$sql);
?>
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Sidral-Carros</title>
</head>
<body>
    <h1>Lista de Carros</h1>
    <table border='3'>
        <tr>
            <th>Modelo</th>
            <th>Ano</th>
            <th>Cor</th>
            <th>Valor-Mercado</th>
        </tr>
        <?php
        // Adiciona as linhas da tabela com os resultados da consulta
        if (\$result->num_rows > 0) {
            while (\$row = \$result->fetch_assoc()) {
                echo \"<tr>
                    <td>{\$row['modelo']}</td>
                    <td>{\$row['ano']}</td>
                    <td>{\$row['cor']}</td>
                    <td>{\$row['valor_mercado']}</td>
                </tr>\";
            }
        } else {
            echo \"<tr><td colspan='4'>Nenhum resultado encontrado</td></tr>\";
        }
        ?>
    </table>
</body>
</html>
<?php
\$conn->close();
?>" | sudo tee /var/www/html/index.php > /dev/null
