use Modern::Perl '2024';

package MilleBornes;

use Moo;
use Game::Deckar;

use Data::Dumper;

my $target_distance = 1000;

my @distance_cards = ( '25 KM', '50 KM', '75 KM', '100 KM', '200 KM', );

my @hazard_cards
    = ( 'Accident', 'Out of Gas', 'Flat Tire', 'Speed Limit', 'Stop', );

my @remedy_cards
    = ( 'Repairs', 'Gasoline', 'Spare Tire', 'End of Limit', 'Roll' );

my @safety_cards
    = ( 'Driving Ace', 'Extra Tank', 'Puncture-Proof', 'Right of Way', );

# cards start in the discard pile so that "draw" is empty which triggers
# a card collection and shuffle

my $game = Game::Deckar->new(
    decks   => [ 'pile', 'discard' ],
    initial => {
        pile => [
            ( $distance_cards[0] ) x 10,
            ( $distance_cards[1] ) x 10,
            ( $distance_cards[2] ) x 10,
            ( $distance_cards[3] ) x 12,
            ( $distance_cards[4] ) x 4,
            ( $hazard_cards[0] ) x 3,
            ( $hazard_cards[1] ) x 3,
            ( $hazard_cards[2] ) x 3,
            ( $hazard_cards[3] ) x 4,
            ( $hazard_cards[4] ) x 5,
            ( $remedy_cards[0] ) x 6,
            ( $remedy_cards[1] ) x 6,
            ( $remedy_cards[2] ) x 6,
            ( $remedy_cards[3] ) x 6,
            ( $remedy_cards[4] ) x 14,
            ( $safety_cards[0] ) x 1,
            ( $safety_cards[1] ) x 1,
            ( $safety_cards[2] ) x 1,
            ( $safety_cards[3] ) x 1,
        ]
    }
);

$game->shuffle('pile');

my %players = (
    'Player 1' => {
        distance => 0,
        hazards  => [],
        remedies => [],
        safety   => [],
    },
    'Player 2' => {
        distance => 0,
        hazards  => [],
        remedies => [],
        safety   => [],
    },
);

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
        # Player's turn
        print "\n$player\'s turn:\n";

        # Draw a card
        #my $drawn_card = $game->pick('pile', $player, [0]);
        my ( $cards, $undo ) = $game->pick( 'pile' => $player, [0] );
        for my $c (@$cards) {
            print "$player drew: '$c'\n";
        }

    DISPLAY:
        # Display player's hand
        print "Distance: $players{$player}{distance}\n";

        my @hand = @{ $game->get($player) };
        print "$player\'s hand: " . join( ", ", @hand ) . "\n";

        # Ask player to choose a card to play
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

        # Play the chosen card
        if ( $played_card =~ / KM$/ ) {
            my ($distance) = $played_card =~ /(\d+)/;

# player can only play a distance card if their new total would be <= the target_distance
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
        }
        elsif ( $played_card =~ /^Hazard/ ) {
            # Implement hazard card logic
            print "$player played $played_card on opponent.\n";
        }
        elsif ( $played_card =~ /^Remedy/ ) {
            # Implement remedy card logic
            print "$player played $played_card.\n";
        }
        elsif ( $played_card =~ /^Safety/ ) {
            # Implement safety card logic
            print "$player played $played_card.\n";
        }

        # Remove the played card from hand
        $game->pick( $player => 'discard', [ $choice - 1 ] );

        # Discard a card if hand size is still over 6
        if ( scalar( $game->get($player) ) > 6 ) {
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
        # Player's turn logic goes here
        # This is where you'd implement the game mechanics for each turn

        # Check if the player has reached the target distance
        if ( $players{$player}{distance} >= $target_distance ) {
            $game_over = 1;
            last;    # Exit the player loop
        }

        $game->pick( 'pile' => $player, [0] );
    }
}

# Game has ended, determine the winner
my $winner = ( sort { $players{$b}{distance} <=> $players{$a}{distance} }
        keys %players )[0];
print "$winner has won the game!\n";

1;
