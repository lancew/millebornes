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
my $message;    # for messages displayed to the user

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

while ( !$game_over ) {
    for my $player ( sort keys %players ) {

        my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';

        my ( $cards, $undo ) = $game->pick( 'pile' => $player, [0] );
        for my $c (@$cards) {
            print "$player drew: '$c'\n";
        }

    DISPLAY:
        _display_header( $player, \%players );

        if ($message) {
            print "\n";
            print $message;
            print "\n\n";
            $message = undef;
        }

        my @hand = @{ $game->get($player) };
        push @hand, 'Discard';
        #print "$player\'s hand: " . join( ", ", @hand ) . "\n";

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
                $message
                    = "You cannot play this card when you cannot move. You need to play a 'Roll' card or a Safety card.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Roll' ) {
            $players{$player}{can_move} = 1;
            $game->pick( $player => 'discard', [ $choice - 1 ] );
            my $hand = $game->get($player);
            goto SKIP_TO_THE_END;
        }

        if ( $played_card =~ / KM$/ ) {

            my ($distance) = $played_card =~ /(\d+)/;

            if ( $players{$player}{distance} + $distance > $target_distance )
            {
                $message
                    = "\Cannot play this distance card. It would exceed the target distance.";
                goto DISPLAY;
            }

            $players{$player}{distance} += $distance;

            $game->pick( $player => 'discard', [ $choice - 1 ] );
            goto SKIP_TO_THE_END;
        }

        if ( $played_card eq 'Stop' || $played_card eq 'Speed Limit' ) {
            unless ( grep { $_ eq 'Right of Way' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0
                    if $played_card eq 'Stop';
                $game->pick( $player => 'discard', [ $choice - 1 ] );

                $message = "$opponent has been stopped.";
                goto SKIP_TO_THE_END;
            }
            else {
                $message
                    = "$opponent is protected by Right of Way. Hazard not applied.\n";
                goto SKIP_TO_THE_END;
            }
        }
        elsif ( $played_card eq 'Out of Gas' ) {
            unless ( grep { $_ eq 'Extra Tank' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                $message = "$opponent is out of gas and cannot move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message
                    = "$opponent is protected by Extra Tank. Hazard not applied.\n";
                goto SKIP_TO_THE_END;
            }
        }
        elsif ( $played_card eq 'Flat Tire' ) {
            unless ( grep { $_ eq 'Puncture-proof' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                $message = "$opponent has a flat tire and cannot move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message
                    = "$opponent is protected by Puncture-proof. Hazard not applied.\n";
                goto DISPLAY;
            }
        }
        elsif ( $played_card eq 'Accident' ) {
            unless ( grep { $_ eq 'Driving Ace' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0;
                $message
                    = "$opponent has been in an Accident and cannot move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message
                    = "$opponent is protected by Driving Ace. Hazard not applied.\n";
                goto DISPLAY;
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

            my $hand = $game->get($player);
            warn Dumper $hand;
        }

    SKIP_TO_THE_END:
        if ( $players{$player}{distance} >= $target_distance ) {
            $game_over = 1;
            last;
        }
    }
}

my $winner = (
    sort { $players{$b}{distance} <=> $players{$a}{distance} }
        keys %players
)[0];
print "$winner has won the game!\n";

sub _display_header {
    my ( $player, $players ) = @_;
    system('clear');

    print "Race to $target_distance km\n\n";
    print "Player 1: $players->{'Player 1'}{distance} km\n";
    print "Player 2: $players->{'Player 2'}{distance} km\n";

    print "\nSafety cards:";
    print join( ", ", @{ $players->{$player}{safety} } ) || "None";

    print "\nRemedy cards:";
    print join( ", ", @{ $players->{$player}{remedies} } ) || "None";

    print "\nHazards:";
    print join( ", ", @{ $players->{$player}{hazards} } ) || "None";

    print "\n$player\'s turn:\n";
    print "Distance: $players->{$player}{distance}\n";

    print "Can move: "
        . ( $players->{$player}{can_move} ? "Yes" : "No" ) . "\n";

}

1;
