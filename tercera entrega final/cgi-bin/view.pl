#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml; charset= UTF-8');

my $owner = $q->param('owner');
my $title = $q->param('title');


print STDERR "$owner $title\n";

my @articlesTex;
if(defined($owner) and defined($title)){
  print STDERR  "se ingreo todos los campos requeridos\n";
  @articlesTex = buscarBD($owner, $title);
  print STDERR "@articlesTex\n";
  print STDERR "tamño de salida de BD";
  
  print STDERR scalar(@articlesTex);
  if(@articlesTex){
    print STDERR  "se encontAo su texto\n";
    print STDERR "este es el texto a cambiar@articlesTex\n";
    my @lineasArticles = split(/\s*\n\s*/,$articlesTex[0]);
    print "  ";
    print interpretar(@lineasArticles);

  }else{
    print STDERR " no se encontAre su texto, revise eus datos\n";
  }
}else{
  print STDERR  "no se lleno todos los campos\n";
}

sub interpretar{

  my @lineas = @_;
  my $len =@lineas;
  my @lineasHTML;
  my $lineaHTML;


  for (my $i = 0; $i < $len ; $i++ ){
    my $linea = $lineas[$i];
    if ($linea =~ /(^#) (.+)/){
      $lineaHTML = "<h1>$2</h1>";
      push(@lineasHTML, $lineaHTML);
    }
  if($linea =~ /(^##) (.+)/){
    $lineaHTML = "<h2>$2</h2>";
    push(@lineasHTML, $lineaHTML);
  }
  if($linea =~ /(^######) (.+)/){
    $lineaHTML = "<h6>$2</h6>";
    push(@lineasHTML, $lineaHTML);
  }


  if($linea =~ /(^\*)(.+)(\*$)/){
    if($2 =~ /(^\*)(.+)(\*$)/){
      if($2 =~ /(^\*)(.+)(\*$)/){
        $lineaHTML = "<p><strong><em>$2</em></strong></p>";
        push(@lineasHTML, $lineaHTML);
      }
      if($2 =~ /(.*)(\_)(.*)(\_)(.*)/){
        $lineaHTML = "<p><strong>$1<em>$3</em>$5</strong></p>";
        push(@lineasHTML, $lineaHTML);
      }
      else{
        $lineaHTML = "<p><em>$2</em></p>";
        push(@lineasHTML, $lineaHTML);
      }
    }else{
      $lineaHTML = "<p><strong>$2</strong></p>";
      push(@lineasHTML, $lineaHTML);
    }

  }

  if($linea =~ /(^\w)(.*)/){   
    my $concate = $1.$2;
    if($concate =~ /(.*)(\[)(.+)(\])(\()(.+)(\))/){
      $lineaHTML = "<p>$1<a href= '$6'>$3</a></p>";
      push(@lineasHTML, $lineaHTML);
    }else{
      $lineaHTML = "<p>$concate</p>";
      push(@lineasHTML, $lineaHTML);
    }
  } elsif($linea =~ /(^\`\`\`)/){  
    my $j=1;
    my $grupoHTML;
    my $lineaHTML= "\n";
    while($lineas[$i+$j] =~ /(^\w)(.*)/){
      $lineaHTML .= $1.$2."\n";
      $j++;
    }

    if($lineas[$i+$j] =~ /(^\`\`\`)/){
      $grupoHTML ="<p><code>$lineaHTML</code></p>";
      print STDERR "$grupoHTML\n";
      push(@lineasHTML, $grupoHTML);
    }

    print STDERR "$i\n";
    $i =$i+$j;
    print STDERR "$i\n";
    print STDERR $lineas[$i];

  }
}
return @lineasHTML;
}


sub buscarBD{
  my $owner =$_[0];
  my $title = $_[1];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "SELECT text FROM Articles WHERE owner=? AND title=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner,$title);
  my @textArticles;
  while(my @row=$sth->fetchrow_array){
    push(@textArticles, @row);

  }

  $sth->finish;
  $dbh->disconnect;
  return @textArticles;
}

#Se crea subrutinas par evaluar cada caracter de manera recursiva
sub evaluarAter{
  my $text =$_[0];
  my $contA =$_[1];
  my $inicio= "";
  my $final = "";
  my @linea;
  if ($text =~ /(.+)([*])(.+)([*])(.*)/){ #el corchette lo vuelve caracter y no es cuantificador
    $inicio .= $1;
    print STDERR "prim$1";
    print STDERR "segun$5";
    $final .= $5;
    print STDERR "ter$3";
    evaluarAter($3);
    $contA++;
    $linea[0]=$inicio;
    $linea[1]=$3;
    $linea[2]= $final;
    return @linea;
  }else{
    return @linea;
  }
}

sub evaluarnumeral{
  my $text = $_[0];
  my $contN = $_[1];
  my @linea;
  if($text =~ /([#])(.+)/){
    $contN++;
    evaluarnumeral($2);
    $linea[0]=$2;
    $linea[1]=$contN;
    return @linea;
  }else{
    return @linea;
  }
}
