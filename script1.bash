#!/bin/bash


#ACTUALIZAMOS 
echo "===== ACTUALIZANDO PAQUETEDE DEPENDECIAS ======"
apt-get update

#INSTALAMOS MARIA DB
echo "===== INSTALANDO MARIA DB ======"
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl status mariadb

#CONFIGURANDO LA BASE DE DATOS
echo "===== CONFIGURANDO BASE DATOS ======"
$ mysql
MariaDB > CREATE DATABASE ecomdb;
MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;

#AGREGANDO DATOS A LA DB
echo "===== AGREGANDO DATO A LA BASE DATOS ======"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF


#EJECUTANDO SCRIPT DE BD
echo "===== EJECUTANDO SCRIPT DE LA BASE DATOS ======"
mysql < db-load-script.sql





#INSTALAMOS APACHE LO HABILITAMOS Y VERIFICAMOS SI ESTA INSTALADO
if dpkg -l |grep -q apache2 ;
then
  echo "===== YA ESTA INSTALADO APACHE ======"
else
  echo "===== INSTALANDO APACHE ======"
  sudo apt install apache2 -y
  echo ===== INICIANDO APACHE ======
  sudo systemctl start apache2
  echo ===== HABILITANDO APACHE ======
  sudo systemctl enable apache
fi


#INSTALAMOS PHP LO HABILITAMOS Y VERIFICAMOS SI ESTA INSTALADO
if dpkg -l |grep -q apache2 ;
then
  echo "===== YA ESTA INSTALADO PHP ======"
else
  echo "===== INSTALANDO PHP ======"
  sudo apt install -y php libapache2-mod-php php-mysql
  echo ===== INICIANDO PHP ======
  sudo systemctl start apache2
  echo ===== HABILITANDO APACHE ======
  sudo systemctl enable apache
fi

#INSTALAMOS GIT Y VERIFICAMOS SI EXISTE ANTES DESPUES CLONAMOS EL REPO Y MOVEMOS LAS FUENTES A APACHE
#REPO="The-DevOps-Journey-101/CLASE-02/"
#if [ -d "$REPO" ] ;
#then
#  echo "la carpeta $REPO existe"
#else
  #git clone -b lamp-app-ecommerce https://github.com/roxsross/The-DevOps-Journey-101.git
#mandamos los archivos a la ruta de apache

#INSTALAMOS GIT Y VERIFICAMOS SI EXISTE
if dpkg -l |grep -q git ;
then
  echo "===== YA ESTA INSTALADO GIT ======"
else
  echo "===== INSTALANDO GIT ======"
  sudo apt install git -y

echo "======= INSTALANDO WEB ==========="
sleep 1
#copiamos el contenido de la carpeta REPO a la carpeta de apache
#cp -r $REPO/* /var/www/html
git clone https://github.com/roxsross/The-DevOps-Journey-101.git
cp -r The-DevOps-Journey-101/CLASE-02/lamp-app-ecommerce/* /var/www/html/
mv /var/www/html/index.html /var/www/html/index.html.bkp


#ACTUALIZAR INDEX
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

              <?php
                        $link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb');
                        if ($link) {
                        $res = mysqli_query($link, "select * from products;");
                        while ($row = mysqli_fetch_assoc($res)) { ?>


#PROBAR QUE ESTE ARRIBA LA PAGINA
curl http://localhost






