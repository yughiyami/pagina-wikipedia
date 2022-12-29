#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml;charset=UTF-8');

my $title = $q->param('title');
my $text = $q->param('text');
my $owner = $q->param('owner');
my @parametros;
push(@parametros, $title);
push(@parametros, $text);
push(@parametros, $owner);
my @salida;
if(validarArray(@parametros)==3){
  insertaBD(@parametros);
  if(buscarBD(@parametros)){
    @salida = buscarBD(@parametros);
    my $cuerpoXML = renderCuerpo(@salida);
    print renderXML($cuerpoXML);
    print STDERR "se encontra\n";
  }else{
    print renderXML(@salida);
    print STDERR "no se inserto sus datos\n";
  }

}else{
  print STDERR "falta campos\n";
    print renderXML(@salida);
}
sub insertaBD{
  my @campos =@_;
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "INSERT INTO Articles (title, owner, text) VALUES(?,?,?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($campos[0],$campos[2],$campos[1]);
  $sth->finish;
  $dbh->disconnect;
}
sub buscarBD{
  my @campos =@_;
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "SELECT title, text FROM Articles WHERE title=? AND owner=? AND text=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($campos[0],$campos[2],$campos[1]);
  my @row =$sth->fetchrow_array;

  $sth->finish;
  $dbh->disconnect;
  return @row;
}
sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
      <article>
        $cuerpoxml
      </article>
XML
  return $xml
}

sub renderCuerpo{
  my @linea = @_;
  my $cuerpo = <<"CUERPO";
      <title>$linea[0]</title>
      <text>$linea[1]</text>
CUERPO
  return $cuerpo;
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
