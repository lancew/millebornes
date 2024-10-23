package MilleBornes::Game;

use Moo;
use Game::Deckar;

has 'target_distance' => (
    is      => 'ro',
    default => 1000,
);

has 'hazards' => (
    is      => 'ro',
    default => sub {
        return [ 'Accident', 'Out of Gas', 'Flat Tire', 'Speed Limit',
            'Stop' ];
    },
);

has 'distances' => (
    is      => 'ro',
    default => sub {
        return [ '25 KM', '50 KM', '75 KM', '100 KM', '200 KM' ];
    },
);

has 'remedies' => (
    is      => 'ro',
    default => sub {
        return [ 'Repairs', 'Gasoline', 'Spare Tire', 'End of Limit',
            'Roll' ];
    },
);

has 'safeties' => (
    is      => 'ro',
    default => sub {
        return [
            'Driving Ace',
            'Extra Tank',
            'Puncture-Proof',
            'Right of Way'
        ];
    },
);

has 'players' => (
    is      => 'ro',
    default => sub {
        return {
            'Player 1' => {
                distance => 0,
                hazards  => [],
                remedies => [],
                safety   => [],
                can_move => 0,
            },
            'Player 2' => {
                distance => 0,
                hazards  => [],
                remedies => [],
                safety   => [],
                can_move => 0,
            },
        };
    },
);

has 'deck' => (
    is      => 'lazy',
    builder => '_build_deck',

);

sub _build_deck {
    my $self = shift;

    my $deck = Game::Deckar->new(
        decks   => [ 'pile', 'discard' ],
        initial => {
            pile => [
                ( $self->distances->[0] ) x 10,
                ( $self->distances->[1] ) x 10,
                ( $self->distances->[2] ) x 10,
                ( $self->distances->[3] ) x 12,
                ( $self->distances->[4] ) x 4,

                ( $self->hazards->[0] ) x 3,
                ( $self->hazards->[1] ) x 3,
                ( $self->hazards->[2] ) x 3,
                ( $self->hazards->[3] ) x 4,
                ( $self->hazards->[4] ) x 5,

                ( $self->remedies->[0] ) x 6,
                ( $self->remedies->[1] ) x 6,
                ( $self->remedies->[2] ) x 6,
                ( $self->remedies->[3] ) x 6,
                ( $self->remedies->[4] ) x 14,

                ( $self->safeties->[0] ) x 1,
                ( $self->safeties->[1] ) x 1,
                ( $self->safeties->[2] ) x 1,
                ( $self->safeties->[3] ) x 1,
            ]
        }
    );

    $deck->shuffle('pile');

    return $deck;
}

sub score {
    my ($self) = @_;
    my %scores;

    for my $player ( keys %{ $self->players } ) {
        my $player_data = $self->players->{$player};

        # Base score: Total distance traveled
        $scores{$player} = $player_data->{distance};

        # Bonus for completing the trip
        if ( $player_data->{distance} >= $self->target_distance ) {
            $scores{$player} += 400;
        }

        # Bonus for each safety card played
        $scores{$player} += 100 * scalar( @{ $player_data->{safety} } );

        # Bonus for all 4 safety cards
        if ( scalar( @{ $player_data->{safety} } ) == 4 ) {
            $scores{$player} += 300;
        }

        # Bonus for Coup Fourré (if implemented)
        # This would require additional tracking in the game logic
        # $scores{$player} += 300 * $player_data->{coup_fourre_count};

        # Bonus for shutout (if opponent's distance is 0)
        my ($opponent) = grep { $_ ne $player } keys %{ $self->players };
        if ( $self->players->{$opponent}->{distance} == 0 ) {
            $scores{$player} += 500;
        }
    }

    return %scores;

}

1;
