use Modern::Perl '2024';

package MilleBornes;

use Moo;
use Game::Deckar;

use lib 'lib';
use MilleBornes::Game;

use Data::Dumper;
$Data::Dumper::Indent = $Data::Dumper::Sortkeys = 1;

my $mb_game = MilleBornes::Game->new();

my $target_distance = $mb_game->target_distance;

my @distance_cards = @{ $mb_game->distances };
my @hazard_cards   = @{ $mb_game->hazards };
my @remedy_cards   = @{ $mb_game->remedies };
my @safety_cards   = @{ $mb_game->safeties };

my $game = $mb_game->deck;

my %players = %{ $mb_game->players };

for my $player ( keys %players ) {
    $game->add_deck($player);
}

for ( 1 .. 6 ) {
    for my $player ( keys %players ) {
        $game->deal( 'pile', $player );
    }
}

my $game_over = 0;

print "Race to $target_distance km\n";

while ( !$game_over ) {
    for my $player ( sort keys %players ) {

        my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';
        print "\n$player\'s turn:\n";

        my ( $cards, $undo ) = $game->pick( 'pile' => $player, [0] );
        for my $c (@$cards) {
            print "$player drew: '$c'\n";
        }

    DISPLAY:
        print "Distance: $players{$player}{distance}\n";

        print Dumper( \%players );

        print "Can move: "
            . ( $players{$player}{can_move} ? "Yes" : "No" ) . "\n";

        my @hand = @{ $game->get($player) };
        push @hand, 'Discard';
        print "$player\'s hand: " . join( ", ", @hand ) . "\n";

        print "Choose a card to play (enter the number): \n";
        for my $i ( 0 .. $#hand ) {
            print $i + 1 . ". $hand[$i]\n";
        }

        my $choice;
        do {
            print "Enter your choice (1-" . scalar(@hand) . "): ";
            $choice = <STDIN>;
            chomp $choice;
            } until ( $choice =~ /^\d+$/
                && $choice >= 1
                && $choice <= scalar(@hand) );

        my $played_card = $hand[ $choice - 1 ];

        if ( !$players{$player}{can_move} ) {
            if ( !grep { $_ eq $played_card }
                ( @safety_cards, @hazard_cards, 'Roll', 'Discard' ) )
            {
                print
                    "\nYou cannot play this card when you cannot move. You need to play a 'Roll' card or a Safety card.\n";
                print "Please choose another card.\n";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Roll' ) {
            $players{$player}{can_move} = 1;
            print "$player rolled the dice and can move again.\n";
            $game->pick( $player => 'discard', [ $choice - 1 ] );
        }

        if ( $played_card =~ / KM$/ ) {

            my ($distance) = $played_card =~ /(\d+)/;

            if ( $players{$player}{distance} + $distance > $target_distance )
            {
                print
                    "\n\nCannot play this distance card. It would exceed the target distance.\n\n";
                print "Please choose another card.\n";
                goto DISPLAY;
            }

            $players{$player}{distance} += $distance;
            print
                "$player played $played_card. Total distance: $players{$player}{distance}\n";

            $game->pick( $player => 'discard', [ $choice - 1 ] );
        }

        if ( $played_card eq 'Stop' || $played_card eq 'Speed Limit' ) {
            unless ( grep { $_ eq 'Right of Way' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0
                    if $played_card eq 'Stop';
                $game->pick( $player => 'discard', [ $choice - 1 ] );
            }
            else {
                print
                    "$opponent is protected by Right of Way. Hazard not applied.\n";
            }
        }
        elsif ( $played_card eq 'Out of Gas' ) {
            unless ( grep { $_ eq 'Extra Tank' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                print "$opponent is out of gas and cannot move!\n";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
            }
            else {
                print
                    "$opponent is protected by Extra Tank. Hazard not applied.\n";
            }
        }
        elsif ( $played_card eq 'Flat Tire' ) {
            unless ( grep { $_ eq 'Puncture-proof' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                print "$opponent has a flat tire and cannot move!\n";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
            }
            else {
                print
                    "$opponent is protected by Puncture-proof. Hazard not applied.\n";
            }
        }
        elsif ( $played_card eq 'Accident' ) {
            unless ( grep { $_ eq 'Driving Ace' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                print "$opponent has been in an Accident and cannot move!\n";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
            }
            else {
                print
                    "$opponent is protected by Driving Ace. Hazard not applied.\n";
            }
        }

        if ( scalar( @{ $game->get($player) } ) > 6 ) {
            print "Choose a card to discard (enter the number): \n";
            @hand = @{ $game->get($player) };

            for my $i ( 0 .. $#hand ) {
                print $i + 1 . ". $hand[$i]\n";
            }

            do {
                print "Enter your choice (1-" . scalar(@hand) . "): ";
                $choice = <STDIN>;
                chomp $choice;
                } until ( $choice =~ /^\d+$/
                    && $choice >= 1
                    && $choice <= scalar(@hand) );

            my $discarded_card = $hand[ $choice - 1 ];
            $game->pick( $player => 'discard', [ $choice - 1 ] );
            print "$player discarded $discarded_card\n";
        }

        if ( $players{$player}{distance} >= $target_distance ) {
            $game_over = 1;
            last;
        }

        $game->pick( 'pile' => $player, [0] );
    }
}

my $winner = (
    sort { $players{$b}{distance} <=> $players{$a}{distance} }
        keys %players
)[0];
print "$winner has won the game!\n";

1;
