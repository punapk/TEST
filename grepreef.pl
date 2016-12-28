#!/usr/local/bin/perl -I/osbexp/pgm/lib -I/cendrillon/bin 

use strict ;
use Getopt::Long ;
use POSIX qw( strftime ) ;
use OSBOO ;
use OSBOO::Tools ;
use InitCendrillon ;


use vars qw(
         $VERS
         $DATEVERS
         $oOSB
         $oTOOLS
) ;


################################
#  CODES EXIT
################################
## exit code 1 : les arguments manquent ou sont incomplets
## exit code 2 : la variable n'a pas ete mis a jour dans le delai demande en nb secondes


BEGIN {
        print <<EOQ;
--------------------------------
${\strftime('%a %F %T',localtime)}

EOQ
}

END {
        print <<EOQ ;
-------------------------------

EOQ
}


################################
#  VARIABLES 
################################

my ($rep_even,$value, $nouvelle_var);


################################
#  ARGUMENTS
################################
GetOptions (
	"even:s"		=> \$rep_even,
	"value:s" 	=> \$value,
	"help"		=> \&usage
) ;



################################
#  VERIFICATION DES ARGUMENTS
################################

#unless ( ($varautosys ne '') && ($value ne '') && ($nb ne '') ) {
#		usage() ;
#}
sub usage {
	print "Usage : $0 --var=VARENV --value=VALEUR --nb=nombre de repetitions(en secondes)\n" ;
	print "\tPositionnement de la valeur \"VALEUR\" dans la variable d\'environnement autosys \"VARENV\"\n" ;
	print "\tVerification de la valeur de variable toutes les 5 seconades fois toutes les secondes\n" ;
	exit( 0 ) ;
}

# Creation instance objet OSB
# ---------------------------
unless( $oOSB = OSBOO->new( DEBUG => 1 ) ) {
        OSBOO::exit_error(1, "Creation objet OSBOO impossible : [$!]") ;
}
$oOSB->log_debug('Objet OSBOO cree') ;
unless( $oTOOLS = OSBOO::Tools->new() ) {
        $oOSB->exit_error(1, "Creation objet OSBTools impossible : [$!]") ;
}
$oOSB->log_debug('Objet OSBTools cree') ;

################################
# BOUCLE PRINCIPALE
################################

my $jrn_reef = "$REPEVEN/$rep_even/JOURNAL.reef";
my %dauto;
my %rauto;
my ($id_transaction,$porteur,$autor,$date,$date_expi,$code_reponse);

unless (-f $jrn_reef){
	print "Fichier $jrn_reef inexistant";
	exit(2);
}


open(JRNREEF,"<$jrn_reef");
while ( defined my $ligne = <JRN_REEF>){
	$id_transaction = substr($ligne,27,18);
	if (($ligne ~ m/DAUTO/) && ($ligne ~ m/$value/)){
		$dauto{$id_transaction}={'Porteur' => substr($ligne,64,19),
								 'Montant' => substr($ligne,89,12),
								 'Heure'   => substr($ligne,137,6),
								 'Date'    => substr($ligne,143,4),
								 'Expiration' => substr($ligne,147,4),
								 'Id_accepteur' => substr($ligne,180,15)};
	}
	if (($ligne ~ m/RAUTO/) && ($ligne ~ m/$value/)){
		$rauto{$id_transaction}={'Porteur' => substr($ligne,64,19),
								 'Heure'   => substr($ligne,105,6),
								 'Date'	   => substr($ligne,111,4),
								 'Expiration' => substr($ligne,115,4),
								 'Autor'	=> substr($ligne,130,6),
								 'Reponse'	=> substr($ligne,136,2)};
	}
}
close (JRNREEF);

foreach my $id (keys %dauto){
	print "$dauto{$id}{Porteur}  $dauto{$id}{Montant}  $dauto{$id}{Expiration}  $rauto{$id}{Autor}  $rauto{$id}{Reponse}";
}



