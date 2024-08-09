#!/bin/bash

############ VARIABLES ###############
REPO="The-DevOps-Journey-101"
USERID=$(id -u)
#COLORES NO FUNCIONAN
#LRED='\033[1;31m'
#LGREEN='\033[1;32m'
#NC='\033[0m'
#LBLUE='\033[0;34m'
#LYELLOW='\033[1;33m'
#####################################

############### VERIFICAMOS USUARIO ROOT  ########################
if [ "${USERID}" -ne 0 ];
then
    echo -e "\DEBES SER ROOT PARA EJECUTAR"
    exit
fi    
##################################################################


############### ACTUALIZAMOS DEPENDENCIAS ########################
apt-get update
echo "===== EL SERVIDOR ESTA ACTUALIZADO ======"
##################################################################


############ INSTALACION DE PAQUETES DEL SISTEMA ##################

echo "===== INSTALANDO PAQUETES ======"

#APACHE
if dpkg -l |grep -q apache2 ;
then
  echo "===== YA ESTA INSTALADO APACHE ======"
else
    echo "===== INSTALANDO APACHE ======"
    sudo apt install apache2 -y
fi

#PHP
if dpkg -l |grep -q php ;
then
  echo "===== YA ESTA INSTALADO PHP ======"
else
    echo "===== INSTALANDO PHP ======"
    sudo apt install -y php libapache2-mod-php php-mysql
fi


#MARIA DB
if dpkg -l |grep -q mysql ;
then
  echo "===== YA ESTA INSTALADO MYSQL MARIA DB ======"
else
    echo "===== INSTALANDO MARIA DB ======"
    sudo apt install -y mariadb-server
fi


#GIT
if dpkg -l |grep -q git ;
then
  echo "===== YA ESTA INSTALADO GIT ======"
else
    echo "===== INSTALANDO GIT ======"
    sudo apt install git -y
fi


#CURL
if dpkg -l |grep -q curl ;
then
  echo "===== YA ESTA INSTALADO CURL ======"
else
    echo "===== INSTALANDO CURL ======"
    sudo apt install curl
fi
####################################################################



############ HABILITACION DE PAQUETES DEL SISTEMA ##################

#APACHE
echo ===== INICIANDO APACHE ======
sudo systemctl start apache2
echo ===== HABILITANDO APACHE ======
sudo systemctl enable apache2
echo ===== STATUS APACHE ======
sudo systemctl status apache2 | grep Active
#renombramos para que tome nuestro index
mv /var/www/html/index.html /var/www/html/index.html.bkp


#PHP
echo ===== INICIANDO PHP ======
echo ===== STATUS y VERSION PHP ======
sudo php -v

#MARIA DB
echo ===== INICIANDO MARIA DB ======
sudo systemctl start mariadb
echo ===== HABILITANDO MARIA DB ======
sudo systemctl enable mariadb
echo ===== STATUS MARIA DB ======
sudo systemctl status mariadb | grep Active

#GIT
echo ===== STATUS GIT ======
sudo git --version


#CURL
echo ===== STATUS CURL ======
sudo curl --version

####################################################################



############# CONFIGURANDO BD #####################
echo "===== CREANDO DB ========"
mysql -e "
CREATE DATABASE ecomdb;
CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
FLUSH PRIVILEGES;"

echo "===== AGREGANDO DATOS A LA DB ========"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

echo "===== EJECUTANDO SCRIPT DB ========"
mysql < db-load-script.sql




###############  BUILD ########################
echo "===== VERIFICAMOS SI EXISTE LA CARPETA DEL REPOSITORIO, SI NO EXISTE LA CLONAMOS ======"

if [ -d "$REPO" ] ;
then
  echo "la carpeta $REPO existe"
else
  git clone https://github.com/roxsross/The-DevOps-Journey-101.git
fi

echo "===== MOVIENDO ARCHIVOS A CARPETA APACHE /var/www/html/ ======"
cp -r The-DevOps-Journey-101/CLASE-02/lamp-app-ecommerce/* /var/www/html/



################ UPDATE INDEX PHP ###############################
echo "===== UPDATE INDEX PHP ======"
sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php



################### REINICIANDO APACHE ###########################
echo "===== REINICIANDO APACHE ======"
systemctl reload apache2
#################################################################

#################################################################
#################################################################


################### TESTEAR CONEXION ###########################
echo "===== TESTEAR CONEXION ======"
curl http://localhost
##################################################################