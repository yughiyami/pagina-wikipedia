#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

my $userName = $q->param('userName');
my $password = $q->param('password');
my $firstName = $q->param('firstName');
my $lastName = $q->param('lastName');
my @parametros;
push(@parametros, $userName);
push(@parametros, $password);
push(@parametros, $firstName);
push(@parametros, $lastName);
print STDERR length($userName);

#print @parametros;
my $len =scalar(@parametros) ;
#print "tamña$len\n";
my @salida;
print STDERR "validacion".validarArray(@parametros);
if(validarArray(@parametros)==4){
  insertaBD(@parametros);
  @salida = @parametros;
  my $cuerpoXML= renderCuerpo(@salida);
  print renderXML($cuerpoXML);

}else{
  print renderXML(@salida);
}
#print STDERR "$userName\n$password\n$firstName\n$lastName";
sub insertaBD{
  my @campos =@_;
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "INSERT INTO Users(userName,password,firstName,lastName)VALUES(?,?,?,?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($campos[0],$campos[1],$campos[2],$campos[3]);
  $sth->finish;
  $dbh->disconnect;

}

sub renderCuerpo{
  my @linea = @_;
  my $cuerpo = <<"CUERPO";
      <owner>$linea[0]</owner>
      <firstName>$linea[2]</firstName>
      <lastName>$linea[3]</lastName>
CUERPO
  return $cuerpo;
}

sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
  <user>
  $cuerpoxml
  </user>
XML
  return $xml
}

sub validarArray{
  my @array = @_;
  my $contador=0;
  foreach my $elemento(@array){
    if (defined($elemento)){
      $contador++;
    }
  }
  return $contador;
}
