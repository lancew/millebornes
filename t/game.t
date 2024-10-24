use Test2::V0;

use lib 'lib';
use MilleBornes::Game;

my $game = MilleBornes::Game->new();

subtest 'Basic tests of object' => sub {

    is $game->target_distance, 1000, 'target distance should be 1000';

    is $game->players,
        {
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
        },
        'players should be expected hashref';

    is $game->distances, [ '25 KM', '50 KM', '75 KM', '100 KM', '200 KM' ],
        'distance should be expected arrayref';
    is $game->hazards,
        [ 'Accident', 'Out of Gas', 'Flat Tire', 'Speed Limit', 'Stop' ],
        'hazards should be expected arrayref';
    is $game->remedies,
        [ 'Repairs', 'Gasoline', 'Spare Tire', 'End of Limit', 'Roll' ],
        'remedies should be expected arrayref';
    is $game->safeties,
        [ 'Driving Ace', 'Extra Tank', 'Puncture-Proof', 'Right of Way' ],
        'safety should be expected arrayref';

    isa_ok $game->deck, 'Game::Deckar';
    is scalar @{ $game->deck->get('pile') }, 106,
        'pile should have 106 cards';

};

subtest 'Score Calculation Tests' => sub {
    # Test 1: Base score (Total distance traveled)
    my $game = MilleBornes::Game->new();
    $game->players->{'Player 1'}{distance} = 500;
    $game->players->{'Player 2'}{distance} = 300;
    my %scores = $game->score;
    is $scores{'Player 1'}, 500, 'Player 1 base score should be 500';
    is $scores{'Player 2'}, 300, 'Player 2 base score should be 300';

    # Test 2: Bonus for completing the trip
    $game = MilleBornes::Game->new();
    $game->players->{'Player 1'}{distance} = 1000;
    $game->players->{'Player 2'}{distance} = 1;    # to avoid shutout bonus
    %scores                                = $game->score;
    is $scores{'Player 1'}, 1400,
        'Player 1 score should be 1400 with trip completion bonus';

    # Test 3: Bonus for each safety card played
    $game = MilleBornes::Game->new();
    $game->players->{'Player 1'}{safety} = [ 'Driving Ace', 'Extra Tank' ];
    $game->players->{'Player 2'}{distance} = 1;    # to avoid shutout bonus
    %scores                                = $game->score;
    is $scores{'Player 1'}, 200,
        'Player 1 score should be 200 with 2 safety cards';

    # Test 4: Bonus for all 4 safety cards
    $game = MilleBornes::Game->new();
    $game->players->{'Player 1'}{distance} = 0;
    $game->players->{'Player 2'}{distance} = 1;    # to avoid shutout bonus
    $game->players->{'Player 1'}{safety}
        = [ 'Driving Ace', 'Extra Tank', 'Puncture-Proof', 'Right of Way' ];

    %scores = $game->score;
    is $scores{'Player 1'}, 700,
        'Player 1 score should be 700 with all 4 safety cards';

    # Test 5: Bonus for shutout (if opponent's distance is 0)
    $game = MilleBornes::Game->new();
    $game->players->{'Player 1'}{distance} = 1000;
    $game->players->{'Player 1'}{safety}
        = [ 'Driving Ace', 'Extra Tank', 'Puncture-Proof', 'Right of Way' ];
    $game->players->{'Player 2'}{distance} = 0;
    %scores = $game->score;
    is $scores{'Player 1'}, 2600,
        'Player 1 score should be 2600 with shutout bonus';
    is $scores{'Player 2'}, 0,
        'Player 2 score should be 0 with no distance traveled';

};

done_testing;

