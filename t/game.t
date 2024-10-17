use Test2::V0;

use lib 'lib';
use MilleBornes::Game;

my $game = MilleBornes::Game->new();

is $game->target_distance, 1000, 'target distance should be 1000';

is $game->players, {
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
}, 'players should be expected hashref';

is $game->distances, ['25 KM', '50 KM', '75 KM', '100 KM', '200 KM'], 'distance should be expected arrayref';
is $game->hazards, ['Accident', 'Out of Gas', 'Flat Tire', 'Speed Limit', 'Stop'], 'hazards should be expected arrayref';
is $game->remedies, ['Repairs', 'Gasoline', 'Spare Tire', 'End of Limit', 'Roll'], 'remedies should be expected arrayref';
is $game->safeties, ['Driving Ace', 'Extra Tank', 'Puncture-Proof', 'Right of Way'], 'safety should be expected arrayref';

isa_ok $game->deck, 'Game::Deckar';
is scalar @{$game->deck->get('pile')}, 106, 'pile should have 106 cards';

done_testing;

