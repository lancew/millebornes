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
        $mb_game->display_header( $target_distance, $player, \%players );

        display_progress_bar(
            'Player 1',       $players{'Player 1'}{distance},
            $target_distance, $players{'Player 1'}{can_move}
        );
        display_progress_bar(
            'Player 2',       $players{'Player 2'}{distance},
            $target_distance, $players{'Player 2'}{can_move}
        );
        print "\n";

        if ($message) {
            print "\n";
            print $message;
            print "\n\n";
            $message = undef;
        }

        my @hand = @{ $game->get($player) };
        push @hand, 'Discard';
        #print "$player\'s hand: " . join( ", ", @hand ) . "\n";

        print "\n\n";
        if ( $player eq 'Player 1' ) {
            print "\e[7m $player 's turn \e[0m\n\n";
        }
        else {
            print "$player 's turn \n\n";
        }
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

        if ( $played_card =~ /^(\d+) KM$/ ) {
            my $distance = $1;

            # Check if player can move
            unless ( $players{$player}{can_move} ) {
                $message
                    = "You cannot play a distance card when you're not allowed to move.";
                goto DISPLAY;
            }

            # Check for Speed Limit
            if ( grep { $_ eq 'Speed Limit' }
                @{ $players{$player}{hazards} } )
            {
                if ( $distance > 50 ) {
                    $message
                        = "You can't play a distance card greater than 50 KM due to Speed Limit.";
                    goto DISPLAY;
                }
            }

            # Check if it would exceed target distance
            if ( $players{$player}{distance} + $distance > $target_distance )
            {
                $message
                    = "Cannot play this distance card. It would exceed the target distance.";
                goto DISPLAY;
            }

            # Play the distance card
            $players{$player}{distance} += $distance;
            $game->pick( $player => 'discard', [ $choice - 1 ] );
            $message
                = "$player moved $distance KM. Total distance: $players{$player}{distance} KM.";
            goto SKIP_TO_THE_END;
        }

        if ( $played_card =~ /^(Stop|Out of Gas|Flat Tire|Accident)$/ ) {
            # Check if opponent has no hazards or only a Stop hazard
            if (!@{ $players{$opponent}{hazards} } || 
                (@{ $players{$opponent}{hazards} } == 1 && $players{$opponent}{hazards}[0] eq 'Stop')) {
                # Opponent has no hazards or only a Stop, so this hazard can be played
            } else {
                $message = "Your opponent already has a hazard that is not Stop. You cannot play another hazard.";
                goto DISPLAY;
            }
            unless ( $players{$opponent}{can_move} ) {
                $message
                    = "You cannot play a Hazard card when your opponent is not moving (except for Speed Limit).";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Stop' || $played_card eq 'Speed Limit' ) {
            unless ( grep { $_ eq 'Right of Way' }
                @{ $players{$opponent}{safety} } )
            {
                push @{ $players{$opponent}{hazards} }, $played_card;
                $players{$opponent}{can_move} = 0
                    if $played_card eq 'Stop';
                $game->pick( $player => 'discard', [ $choice - 1 ] );

                $message = "$opponent has been stopped."
                    if $played_card eq 'Stop';
                $message = "$opponent has been slowed by Speed Limit."
                    if $played_card eq 'Speed Limit';
                goto SKIP_TO_THE_END;
            }
            else {
                $message
                    = "$opponent is protected by Right of Way. Hazard not applied.\n";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Out of Gas' ) {
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
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Flat Tire' ) {
            unless ( grep { $_ eq 'Puncture-Proof' }
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

        if ( $played_card eq 'Accident' ) {
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

        if ( $played_card eq 'Repairs' ) {
            if ( grep { $_ eq 'Accident' } @{ $players{$player}{hazards} } ) {
                @{ $players{$player}{hazards} } = grep { $_ ne 'Accident' }
                    @{ $players{$player}{hazards} };
                $players{$player}{can_move} = 0;
                $message = "$player has repaired their car and can now move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You don't have an Accident to repair.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Gasoline' ) {
            if ( grep { $_ eq 'Out of Gas' } @{ $players{$player}{hazards} } )
            {
                @{ $players{$player}{hazards} } = grep { $_ ne 'Out of Gas' }
                    @{ $players{$player}{hazards} };
                $players{$player}{can_move} = 0;
                $message = "$player has refueled their car and can now move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You don't need Gasoline right now.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Spare Tire' ) {
            if ( grep { $_ eq 'Flat Tire' } @{ $players{$player}{hazards} } )
            {
                @{ $players{$player}{hazards} } = grep { $_ ne 'Flat Tire' }
                    @{ $players{$player}{hazards} };
                $players{$player}{can_move} = 0;
                $message = "$player has changed their tire and can now move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You don't have a Flat Tire to fix.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'End of Limit' ) {
            if ( grep { $_ eq 'Speed Limit' }
                @{ $players{$player}{hazards} } )
            {
                @{ $players{$player}{hazards} } = grep { $_ ne 'Speed Limit' }
                    @{ $players{$player}{hazards} };
                $message = "$player is no longer under a Speed Limit!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You're not under a Speed Limit.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Roll' ) {
            if ( @{ $players{$player}{hazards} } == 1
                && $players{$player}{hazards}[0] eq 'Stop'
                || $players{$player}{hazards}[0] eq 'Speed Limit' )
            {
                @{ $players{$player}{hazards} } = ();
                $players{$player}{can_move} = 1;
                $message = "$player can now move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            elsif (
                @{ $players{$player}{hazards} } > 1
                || ( @{ $players{$player}{hazards} } == 1
                    && $players{$player}{hazards}[0] ne 'Stop' )
                )
            {
                $message
                    = "You can't play Roll when you have other hazards besides Stop.";
                goto DISPLAY;
            }
            elsif ( !$players{$player}{can_move} ) {
                $players{$player}{can_move} = 1;
                $message = "$player can now move!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You don't need to play Roll right now.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Driving Ace' ) {
            if ( !grep { $_ eq 'Driving Ace' }
                @{ $players{$player}{safety} } )
            {
                push @{ $players{$player}{safety} }, 'Driving Ace';
                $message = "$player is now protected against Accidents!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You already have the Driving Ace safety card.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Extra Tank' ) {
            if ( !grep { $_ eq 'Extra Tank' } @{ $players{$player}{safety} } )
            {
                push @{ $players{$player}{safety} }, 'Extra Tank';
                $message
                    = "$player is now protected against running Out of Gas!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You already have the Extra Tank safety card.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Puncture-Proof' ) {
            if ( !grep { $_ eq 'Puncture-Proof' }
                @{ $players{$player}{safety} } )
            {
                push @{ $players{$player}{safety} }, 'Puncture-Proof';
                # Remove Flat Tire hazard if present
                @{ $players{$player}{hazards} } = grep { $_ ne 'Flat Tire' }
                    @{ $players{$player}{hazards} };

                $message = "$player is now protected against Flat Tires!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You already have the Puncture-Proof safety card.";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Right of Way' ) {
            if ( !grep { $_ eq 'Right of Way' }
                @{ $players{$player}{safety} } )
            {
                push @{ $players{$player}{safety} }, 'Right of Way';
                $message
                    = "$player is now protected against Speed Limits and Stops!";
                $game->pick( $player => 'discard', [ $choice - 1 ] );
                goto SKIP_TO_THE_END;
            }
            else {
                $message = "You already have the Right of Way safety card.";
                goto DISPLAY;
            }
        }

        # ------------------------------------------------------------
        while ( scalar( @{ $game->get($player) } ) > 6 ) {
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
        }

    SKIP_TO_THE_END:
        if ( $players{$player}{distance} >= $target_distance ) {
            $game_over = 1;
            last;
        }
    }
}

my %scores = $mb_game->score;

print "\n\nScores: \n";
my $winner = ( sort { $scores{$b} <=> $scores{$a} } keys %scores )[0];
for my $player ( sort { $scores{$b} <=> $scores{$a} } keys %scores ) {
    print "$player: $scores{$player}\n";
}

print "\n$winner wins! 🏆\n";

exit;

sub display_progress_bar {
    my ( $player, $distance, $target_distance, $can_move ) = @_;
    my $bar_width = 50;
    my $progress  = int( ( $distance / $target_distance ) * $bar_width );
    my $bar = '[' . '#' x $progress . ' ' x ( $bar_width - $progress ) . ']';
    my $move_indicator = $can_move ? '🚗' : '🛑';
    if (grep { $_ eq 'Speed Limit' } @{ $players{$player}{hazards} }) {
        $move_indicator .= '㉌';
    } else {
        $move_indicator .= ' ';
    }
    if (grep { $_ ne 'Speed Limit' } @{ $players{$player}{hazards} }) {
        $move_indicator .= '⚠️';
    } else {
        $move_indicator .= ' ';
    }
    printf "%-10s %s\n", "$player $move_indicator", $bar;
}

1;

