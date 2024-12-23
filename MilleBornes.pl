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
            my $result = play_distance_card( $player, $1, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card =~ /^(Stop|Out of Gas|Flat Tire|Accident)$/ ) {
            # Check if opponent has no hazards or only a Stop hazard
            if (!@{ $players{$opponent}{hazards} }
                || ( @{ $players{$opponent}{hazards} } == 1
                    && $players{$opponent}{hazards}[0] eq 'Stop' )
                )
            {
        # Opponent has no hazards or only a Stop, so this hazard can be played
            }
            else {
                $message
                    = "Your opponent already has a hazard that is not Stop. You cannot play another hazard.";
                goto DISPLAY;
            }
            unless ( $players{$opponent}{can_move} ) {
                $message
                    = "You cannot play a Hazard card when your opponent is not moving (except for Speed Limit).";
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Stop' ) {
            my $result = play_stop( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Speed Limit' ) {
            my $result = play_speed_limit( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Out of Gas' ) {
            my $result = play_out_of_gas( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Flat Tire' ) {
            my $result = play_flat_tire( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Accident' ) {
            my $result = play_accident( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Repairs' ) {
            my $result = play_repairs( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Gasoline' ) {
            my $result = play_gasoline( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Spare Tire' ) {
            my $result = play_spare_tire( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'End of Limit' ) {
            my $result = play_end_of_limit( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Roll' ) {
            my $result = play_roll( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Driving Ace' ) {
            my $result = play_driving_ace( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Extra Tank' ) {
            my $result = play_extra_tank( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Puncture-Proof' ) {
            my $result = play_puncture_proof( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
                goto DISPLAY;
            }
        }

        if ( $played_card eq 'Right of Way' ) {
            my $result = play_right_of_way( $player, $choice );
            if ( $result->{success} ) {
                $message = $result->{message};
                goto SKIP_TO_THE_END;
            }
            else {
                $message = $result->{message};
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
    if ( grep { $_ eq 'Speed Limit' } @{ $players{$player}{hazards} } ) {
        $move_indicator .= '㉌';
    }
    else {
        $move_indicator .= ' ';
    }
    if ( grep { $_ eq 'Out of Gas' } @{ $players{$player}{hazards} } ) {
        $move_indicator .= '⛽';
    }
    elsif ( grep { $_ ne 'Speed Limit' } @{ $players{$player}{hazards} } ) {
        $move_indicator .= '⚠️';
    }
    else {
        $move_indicator .= ' ';
    }

    printf "%-10s %s\n", "$player $move_indicator", $bar;
}

sub play_distance_card {
    my ( $player, $distance, $choice ) = @_;

    # Check if player can move
    unless ( $players{$player}{can_move} ) {
        return {
            success => 0,
            message =>
                "You cannot play a distance card when you're not allowed to move."
        };
    }

    # Check for Speed Limit
    if ( grep { $_ eq 'Speed Limit' } @{ $players{$player}{hazards} } ) {
        if ( $distance > 50 ) {
            return {
                success => 0,
                message =>
                    "You can't play a distance card greater than 50 KM due to Speed Limit."
            };
        }
    }

    # Check if it would exceed target distance
    if ( $players{$player}{distance} + $distance > $target_distance ) {
        return {
            success => 0,
            message =>
                "Cannot play this distance card. It would exceed the target distance."
        };
    }

    # Play the distance card
    $players{$player}{distance} += $distance;
    $game->pick( $player => 'discard', [ $choice - 1 ] );
    return {
        success => 1,
        message =>
            "$player moved $distance KM. Total distance: $players{$player}{distance} KM."
    };
}

sub play_right_of_way {
    my ( $player, $choice ) = @_;

    if ( !grep { $_ eq 'Right of Way' } @{ $players{$player}{safety} } ) {
        push @{ $players{$player}{safety} }, 'Right of Way';
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message =>
                "$player is now protected against Speed Limits and Stops!"
        };
    }
    else {
        return {
            success => 0,
            message => "You already have the Right of Way safety card."
        };
    }
}

sub play_puncture_proof {
    my ( $player, $choice ) = @_;

    if ( !grep { $_ eq 'Puncture-Proof' } @{ $players{$player}{safety} } ) {
        push @{ $players{$player}{safety} }, 'Puncture-Proof';
        # Remove Flat Tire hazard if present
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Flat Tire' } @{ $players{$player}{hazards} };

        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player is now protected against Flat Tires!"
        };
    }
    else {
        return {
            success => 0,
            message => "You already have the Puncture-Proof safety card."
        };
    }
}

sub play_extra_tank {
    my ( $player, $choice ) = @_;

    if ( !grep { $_ eq 'Extra Tank' } @{ $players{$player}{safety} } ) {
        push @{ $players{$player}{safety} }, 'Extra Tank';
        # Remove Out of Gas hazard if present
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Out of Gas' } @{ $players{$player}{hazards} };

        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player is now protected against running Out of Gas!"
        };
    }
    else {
        return {
            success => 0,
            message => "You already have the Extra Tank safety card."
        };
    }
}

sub play_driving_ace {
    my ( $player, $choice ) = @_;

    if ( !grep { $_ eq 'Driving Ace' } @{ $players{$player}{safety} } ) {
        push @{ $players{$player}{safety} }, 'Driving Ace';
        # Remove Accident hazard if present
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Accident' } @{ $players{$player}{hazards} };

        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player is now protected against Accidents!"
        };
    }
    else {
        return {
            success => 0,
            message => "You already have the Driving Ace safety card."
        };
    }
}

sub play_roll {
    my ( $player, $choice ) = @_;

    if ( @{ $players{$player}{hazards} } == 1
        && $players{$player}{hazards}[0] eq 'Stop'
        || $players{$player}{hazards}[0] eq 'Speed Limit' )
    {
        @{ $players{$player}{hazards} } = ();
        $players{$player}{can_move} = 1;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player can now move!"
        };
    }
    elsif (
        @{ $players{$player}{hazards} } > 1
        || ( @{ $players{$player}{hazards} } == 1
            && $players{$player}{hazards}[0] ne 'Stop' )
        )
    {
        return {
            success => 0,
            message =>
                "You can't play Roll when you have other hazards besides Stop."
        };
    }
    elsif ( !$players{$player}{can_move} ) {
        $players{$player}{can_move} = 1;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player can now move!"
        };
    }
    else {
        return {
            success => 0,
            message => "You don't need to play Roll right now."
        };
    }
}

sub play_end_of_limit {
    my ( $player, $choice ) = @_;

    if ( grep { $_ eq 'Speed Limit' } @{ $players{$player}{hazards} } ) {
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Speed Limit' } @{ $players{$player}{hazards} };
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player is no longer under a Speed Limit!"
        };
    }
    else {
        return {
            success => 0,
            message => "You're not under a Speed Limit."
        };
    }
}

sub play_spare_tire {
    my ( $player, $choice ) = @_;

    if ( grep { $_ eq 'Flat Tire' } @{ $players{$player}{hazards} } ) {
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Flat Tire' } @{ $players{$player}{hazards} };
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player has changed their tire and can now move!"
        };
    }
    else {
        return {
            success => 0,
            message => "You don't have a Flat Tire to fix."
        };
    }
}

sub play_gasoline {
    my ( $player, $choice ) = @_;

    if ( grep { $_ eq 'Out of Gas' } @{ $players{$player}{hazards} } ) {
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Out of Gas' } @{ $players{$player}{hazards} };
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player has refueled their car and can now move!"
        };
    }
    else {
        return {
            success => 0,
            message => "You don't need Gasoline right now."
        };
    }
}

sub play_repairs {
    my ( $player, $choice ) = @_;

    if ( grep { $_ eq 'Accident' } @{ $players{$player}{hazards} } ) {
        @{ $players{$player}{hazards} }
            = grep { $_ ne 'Accident' } @{ $players{$player}{hazards} };
        $players{$player}{can_move} = 1;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$player has repaired their car and can now move!"
        };
    }
    else {
        return {
            success => 0,
            message => "You don't have an Accident to repair."
        };
    }
}

sub play_accident {
    my ( $player, $choice ) = @_;
    my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';

    unless ( grep { $_ eq 'Driving Ace' } @{ $players{$opponent}{safety} } ) {
        push @{ $players{$opponent}{hazards} }, 'Accident';
        $players{$opponent}{can_move} = 0;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$opponent has been in an Accident and cannot move!"
        };
    }
    else {
        return {
            success => 0,
            message =>
                "$opponent is protected by Driving Ace. Hazard not applied."
        };
    }
}

sub play_flat_tire {
    my ( $player, $choice ) = @_;
    my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';

    unless ( grep { $_ eq 'Puncture-Proof' }
        @{ $players{$opponent}{safety} } )
    {
        push @{ $players{$opponent}{hazards} }, 'Flat Tire';
        $players{$opponent}{can_move} = 0;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$opponent has a flat tire and cannot move!"
        };
    }
    else {
        return {
            success => 0,
            message =>
                "$opponent is protected by Puncture-proof. Hazard not applied."
        };
    }
}

sub play_out_of_gas {
    my ( $player, $choice ) = @_;
    my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';

    unless ( grep { $_ eq 'Extra Tank' } @{ $players{$opponent}{safety} } ) {
        push @{ $players{$opponent}{hazards} }, 'Out of Gas';
        $players{$opponent}{can_move} = 0;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$opponent is out of gas and cannot move!"
        };
    }
    else {
        return {
            success => 0,
            message =>
                "$opponent is protected by Extra Tank. Hazard not applied."
        };
    }
}

sub play_speed_limit {
    my ( $player, $choice ) = @_;
    my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';
    if ( grep { $_ eq 'Speed Limit' } @{ $players{$opponent}{hazards} } ) {
        return {
            success => 0,
            message => "$opponent already has a Speed Limit hazard."
        };
    }

    unless ( grep { $_ eq 'Right of Way' } @{ $players{$opponent}{safety} } )
    {
        push @{ $players{$opponent}{hazards} }, 'Speed Limit';
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$opponent has been slowed by Speed Limit."
        };
    }
    else {
        return {
            success => 0,
            message =>
                "$opponent is protected by Right of Way. Speed Limit not applied."
        };
    }
}

sub play_stop {
    my ( $player, $choice ) = @_;
    my $opponent = ( $player eq 'Player 1' ) ? 'Player 2' : 'Player 1';

    unless ( grep { $_ eq 'Right of Way' } @{ $players{$opponent}{safety} } )
    {
        push @{ $players{$opponent}{hazards} }, 'Stop';
        $players{$opponent}{can_move} = 0;
        $game->pick( $player => 'discard', [ $choice - 1 ] );
        return {
            success => 1,
            message => "$opponent has been stopped."
        };
    }
    else {
        return {
            success => 0,
            message =>
                "$opponent is protected by Right of Way. Stop not applied."
        };
    }
}

1;

