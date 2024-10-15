# Implementing the Mile Bornes game in Perl.

Based on info here: https://en.wikibooks.org/wiki/Card_Games/Mille_Bornes

Using:

* plenv
* carmel
* Game::Deckar

install dependencies with `carmel install`

run game with `carmel exec perl game.pl`

A lot of this code is being produced by AI, this is an experiment in how well it does.

---

Mille Bornes (also Mille Bournes) is a French card game. In the United States, Mille Bornes is published by Parker Brothers and is commonly available in game stores, as well as toy stores and department store]]s. There are also several computer-based versions. It is believed to be based on Touring (card game)|Touring, an earlier American card game.

Some Mille Bornes decks are printed in both English and French language. In the Netherlands, this game is known as rijwielspel, and deals with cycling instead of driving. The hazards and distances are different, but the mechanics of the game are exactly the same.

The premise of Mille Bornes is that the players are in a Auto racing. Each "race", or hand, is usually 700 miles or kilometers long (1000 for the standard 4-player game), but the first player to complete that distance exactly has the option to declare an extension in which case the race becomes 1000 miles, hence the name of the game which means "one thousand milestones". The object of the game is to reach 5000 points, which normally takes several hands.

Mille Bornes is listed in the GAMES Magazine Hall of Fame.
Playing the game
Deck

Mille Bornes is played with a special, unusual deck of cards. There are Hazards, Remedies, Safeties, and Distance cards (km stones). Each hazard is corrected by a corresponding remedy and prevented by a corresponding safety. The object of the game is achieved by playing Distance cards.

Note that the Right of Way card is unique in that it protects against both the Speed Limit and Stop hazards.


Hazards
3x 	3x 	3x 	4x 	5x
width = 60px 	width = 60px 	width = 60px 	width = 60px 	width = 60px
Accident 	Out of Gas 	Flat Tire 	Speed Limit 	Stop
Accident 	Panne d'Essence 	Creve 	Limite de Vitesse 	Stop 	
Remedies
6x 	6x 	6x 	6x 	14x
width = 60px 	width = 60px 	width = 60px 	width = 60px 	width = 60px
Repairs 	Gasoline 	Spare 	End of Limit 	Roll
Reparations 	Essence 	Roue de Secours 	Fin de Limite de Vitesse 	Roulez
Safeties
1x 	1x 	1x 	
1x
width = 60px 	width = 60px 	width = 60px 	
width = 60px
Driving Ace 	Extra Tank 	Puncture-
proof 	
Right of Way
As du Volant 	Citerne d'Essence 	Increvable 	
Vehicule Prioritaire
Distance cards
10x 	10x 	10x 	12x 	4x
width = 60px 	width = 60px 	width = 60px 	width = 60px 	width = 60px
25 km 	50 km 	75 km 	100 km 	200 km


Included in the deck are also nonplayable cards that list the playable cards and summarize the scoring. In some decks, some of these are printed entirely in French.
Play

Mille Bornes is based very loosely on the Rummy family of card games. The deck is shuffled and 6 cards are dealt to each player; the remainder becomes a draw pile and a discard pile forms next to it. Each player's turn begins with a draw of one card and a play of one card, so that each player always holds 6 cards at the end of his turn. If he cannot play he must discard. Discarded cards are dead and cannot be taken for any reason.

Each player (or team) builds a tableau; in team play, only one is built for a single team. This tableau is divided into Battle, Speed, Distance, and Safety areas; cards in the Battle and Speed areas are stacked so that only the top card shows. The example shows a typical tableau midway through a game.

Hazards and Remedies (with the exception of Speed Limit and End of Limit) are played in the Battle Area, where a Roll card is shown in the example. Speed Limit and End of Limit cards are played in their own area. Distance (km stone) cards are played according to value; it's common to play the 200 km cards distinctly, rather than fanned. Safety cards are played along the top of the tableau; note that the horizontal placement of the Extra Tank card in the example has a special significance.

In turn, a player may choose to play one of the following:

    A Distance card on his own tableau if a Roll card is showing in his Battle area

    A Remedy on top of a corresponding Hazard if one is showing in his Battle area

    An End of Limit on top of a Speed Limit if one is showing in his Speed area

    A Hazard on top of his opponent's Roll if one is showing and his opponent has not already played the corresponding Safety

    A Safety in his own Safety area (at any time)

    A Roll card in his own Battle area if a Stop or Remedy is showing, or if his Battle area is empty

Note that a Hazard cannot be played unless one's opponent is "moving", except for the Speed Limit.

Once an Accident, Out of Gas, or Flat Tire Hazard has been played, and the appropriate Repair card played as a counter; one must next play a Roll card to get "moving" again.

Playing a Safety corrects the corresponding Hazard and also protects against future Hazards of this type. However, when the Safety is played normally, a Roll must still be played before any Distance cards. Whenever the Safety is played, the same player draws another card immediately and plays again. It is possible to play another Safety and another, each time drawing a card before playing again.

When a player's speed is limited (as shown in the example) he may only play 25 and 50 km cards. No more than two 200 km cards may be played by any team in a single hand.

The Right of Way card both remedies and protects against Stop and Speed Limit Hazards; if a player (or team) has played this card then he (or they) need not display a Roll card in order to "move"; any Stop or Speed Limit showing is removed to the discard pile at the time the Right of Way card is played. However, the player is still vulnerable to other Hazards.

A player may always discard, even if he has a legal play available. If a player cannot play in any other way he must discard.

Under no circumstances may a Distance card be played that would put one's total over the race goal of 1000 km.

Play continues until either:

    One player (or team) reaches exactly 1000 km in total Distance cards; or

    Every player has played or discarded all his cards.

Note that play continues after the draw pile is exhausted, each player playing or discarding one card per turn.
Coup Fourré

In the event that a player holds the corresponding Safety at the moment when a Hazard is played in his Battle area, he may call "Coup Fourré" and immediately play the Safety in his own Safety area; when doing so the Safety is placed horizontally (as the Extra Tank is shown in the example). The Hazard is removed to the discard pile, revealing the Roll card beneath it. As when any Safety is played, the player who calls Coup Fourré draws another card at once and plays again. Play resumes to his left, not to that of he who played the offending Hazard; thus any intervening players lose their turns.

Note that because the Hazard is removed and not merely corrected by the Coup Fourré, a Roll card now shows and Distance cards may be played immediately. This is an advantage over playing a Safety later (normally), when it merely corrects the Hazard and a Roll card is still required to "move". The exception is the Right of Way card; as soon as it is played (normally or by Coup Fourré) the player is considered to be "moving" (unless he suffers from another Hazard).

The Safety may only be played as a Coup Fourré immediately after the offending Hazard; as soon as the next player plays or discards the opportunity is lost.
Extension

Mille means 1000 and the game is normally played to a total of 1000 km. In some variations it may be agreed that the goal is 700 km, instead. If one player reaches this total then he may choose either to end the hand immediately and collect the appropriate scores for trip completion; or to call Extension, in which case the hand continues to a goal of 1000 km. One must still reach the goal of 700 km exactly either to win the hand or call for extension.

Trip completion itself is worth 400 points in either case; but there is a bonus for the extension itself. Note that it is possible to reach 700 km, call for extension, and fail to reach 1000 km. If one's opponents reach 1000 km first, they collect all trip completion scores and bonuses.
Scoring

When a hand ends it is scored with the following points:

        Scored by each side
        Distance 	1 	per km traveled
        Each safety 	100 	however played
        All 4 safeties 	300 bonus
        Coup-fourré 	300 bonus for each
         
        Scored only by side that completes trip
        Trip completed 	400 	for being the winner
        Delayed action 	300 	for completing the trip after the draw pile is exhausted
        Safe trip 	300 	for completing the trip without playing any 200 km cards
        Extension 	200 	for completing the trip after calling for an Extension
        Shutout 	500 	for completing a trip before the opponent has played any Distance cards 

In a 2-player game, the maximum score that can be made in one hand is 5,000 points. In a standard 4-player game there is no extension, so the maximum score is 4,800. In a 3-player or 6-player game, two shutout bonuses are achievable, yielding a perfect score of 5,500.

Note that some points are scored even if a side does not complete a trip; it is possible for the completing side to score fewer points than their opponents. If the hand ends by exhaustion rather than by completion, each side still scores its distance and safety points.

According to the printed rules distributed by Parker Brothers, a game continues until one or both sides reaches a cumulative point total of 5,000. If both sides go over 5,000 during the same hand, the higher point total wins the game. When the game is played for fun the exact point total is irrelevant, so long as one is higher. Note that it is possible for the game to end in a tie, in which case the rules are silent.

If the game is played for money, then generally the point difference is paid from the loser to the winner, and every point is significant.
With larger or smaller groups

The game is normally played with 4 players in two teams of two each. Each team shares only one tableau. Either player may make a Coup Fourré in response to a Hazard.

When 4 players are not available, the game may be played with some variations.
2 or 3 player version

Three players play cutthroat, each one for himself. In some versions, a player may only play Hazards on the person to his left.

Some rulebooks say that one of each Hazard should be removed, since not having a partner makes it harder to hold a full set of Remedies.

This version is usually played to 700 km with the Extension option, but the normal goal of 1000 km is also playable.
6 player version

This is theoretically possible as two teams of three or three teams of two, but isn't really practical. It is played to 700 km with the Extension option.
Strategy

As in most card games the most important skill is remembering what cards have been played or discarded. Who has discarded may be quite as important as what.

As in other games of the Rummy family, one may spend many turns discarding while waiting for a needed card. It is vital to spend this time improving one's hand; so one must constantly re-evaluate one's hand to determine which card is most discardable. Often this devolves into a choice between the least of several evils.
By card

Safeties:

    The Right of Way card is the most valuable in the deck. Every effort should be made to delay playing it normally, as it can be played in Coup Fourré to a total of 9 Hazards.

    All Safeties should be retained against the corresponding Hazard, as a Coup Fourré is worth bonus points.

    Safeties may always be played and at any time, so there is no excuse for being caught with one in hand at trip completion (and absurd to discard it). Watch the other side's Distance total.

    Ordinarily, when one side reaches 800 km (or 500 if playing to 700) it is time to play all one's Safeties, since a single 200 km would allow the other side to go out. However there are exceptions in which one might retain a Safety while still hoping to use it in Coup Fourré:

        In 2 or 3 player games if another player is "stopped" due to some Hazard (not Stop or End of Limit) then there is no risk of his going out immediately since he must first correct the Hazard before playing any Distance. But in team play the other side will have two opportunities to play -- one partner correcting the Hazard with a Safety and taking the extra turn to play a Roll card, then the other partner playing the fatal 200 km. If the needed Safety is known to be unavailable to the threatening team then one may continue to hold one's own Safety, as it will take 3 distinct turns for the opponents to correct the Hazard, Roll, and play any Distance.

        In 2 or 3 player games another player may be "stopped", having corrected the Hazard, while waiting for a Roll card; or may be "stopped" with a Stop. In this case it may be safe to retain a Safety for the moment. This depends on the possibility that the threatening player may play the Right of Way card and immediately follow it with Distance, ending the hand.

        If the other side is "stopped" due to some Hazard and all of the corresponding Remedies and Safety have been seen then of course they are going no further and there is no threat to catch one's Safety in one's hand. The same may be said when (unusually) all Roll cards and the Right of Way have been seen.

        Although a km total of 800 is clearly threatening, a total of 600 is hazardous if one's opponents have not yet played any 200 km cards. (Recall that it is only permitted to play two of these in a hand.) A total of 700 threatens if only one 200 km card has been played. However, note that odd combinations of Distance, such as 650 km, are not threatening, since no possible combination of two Distance cards could put one's opponents out.

        In 2 or 3 player games one's opponents have only a single opportunity to play before one's own chance comes again, so it is easier to determine if one must relinquish a Safety. 500 (to a goal of 700) is a threat if a 200 km is still available; 550 is not; 600 certainly is; and 650 is threatening even if one's opponent's speed is limited.

        Don't be led astray by the relative values of playing a Safety normally or by Coup Fourré. The former is worth 100 points, the latter a total of 400; so it's tempting to wait. But a corresponding Hazard may remain unplayed; you or your partner may draw it or your opponents may not choose to play it against you. The 100 is a sure thing -- if you are not caught with the Safety in your hand.

Remedies:

    There are 3 each of Accident, Out of Gas, and Flat Tire Hazards (2 each if one has been removed before play). When all of one type has been seen, there's no need to keep the corresponding Remedy or Safety in one's hand. The former may be discarded and the latter played normally.

    There are 4 Speed Limit Hazards (or 3 if one has been removed); again, once all have been seen there is no need to keep any End of Limit Remedies. However the Right of Way should probably be retained.

    There are only 5 Stop cards, but it's not wise to discard Roll cards because you've seen all the Stops. You may still need Rolls in order to get "moving" after another Hazard.

    It's probably wise to retain one of each major Remedy if at all possible; if no corresponding Hazard has been seen, it's essential. It's probably unwise to keep two of the same Remedy and certainly pointless to do so if only one corresponding Hazard remains.

    Discarding a Remedy leads one's opponents to the natural conclusion that one may have the corresponding Safety in hand (or at least another of the same Remedy), thus discouraging them from retaining or playing that Hazard. This opens the door to an element of bluff and the possibility of confusing the other team. If one has a reputation of bluffing then discarding a Remedy may provoke the Hazard, permitting one to Coup Fourré; if one has a reputation for "honesty", then it may be better not to telegraph one's riches by discarding the Remedy.

Hazards:

    Stop and Speed Limit are minor Hazards, the former corrected with a mere Roll and the latter not even entirely "stopping" the opposition. The other, major Hazards are more valuable.

    Retaining two or more of the same Hazard may be dubious. If the corresponding Safety is available to the other team then both Hazards may be rendered useless at a stroke.

    If one's opponent's have already played a given Safety then all corresponding Hazards are worthless; if the Safety is unavailable to them then the Hazards gain in value.

    Count played and discarded Remedies. Each increases the value of the corresponding Hazard and of each remaining Remedy of the same type.

Distance:

    Distance cards are numerous and usually should be discarded before other cards. Discard smaller Distance cards first.

    The need to reach the race goal exactly imposes certain restrictions on the combinations that may be played. It's common to reach a Distance total of, say, 975 km and lose the hand while waiting for a final 25 km; any other Distance cards are useless. It may be wise to hold a 25 km against such a possibility.

    Since 100 km cards are relatively common, one may wish to hesitate before playing smaller values unless one also has others in hand. The closer to the end of the hand, the more important this becomes. When the other team seems about ready to complete a trip it's easy to get flustered and play a lone 25 or 50, because that's all one has got; but it might be wiser to wait and see if another 100 is drawn.

    Playing a lone 50 km card requires that one later play one of the following combinations (to arrive at a round point total): one other 50, two 25s, or two 75s. Thus this is fairly safe.

    Playing a lone 25 km requires a later play of: one 75, one 50 and one 25, or three more 25s. Since one may well have discarded several 25s this may be a risky play.

    Playing a lone 75 km requires a later play of one 75 and one 50, or of one 25. Thus this is the most risky Distance play. It's safer to wait until one has a pair of 75s before playing either, especially close to the end.

    It may be better to discard a 75 km before discarding 25s and 50s -- because of the above-noted disadvantage and also because a 75 exceeds a possible Speed Limit.

    If a player or team has already played two 200 km cards, then any others are worthless. Likewise, there's no need to keep more than two in hand.

By phase of play

Opening:

If you are dealt the Right of Way card, since everyone technically has a Stop, you may play it immediately before anyone else plays as a 'Coup Fourre'. This means you never need a roll and you may draw 2 cards and play one. One may or may not have a Roll card initially dealt; one may or may not have a Hazard initially dealt; one may or may not have first play. Since the other team's hands are completely unknown at first, the primary determinate of opening strategy is one's aggressiveness.

    If one has first play and a Roll card, it's clearly best to play it.

    If you have first play but no Roll card, look for a Speed Limit card before discarding; it is the only Hazard you can play when your opponent is not "moving".

    Lacking a Roll card, you might be tempted to play Right of Way on first play. (See above)Don't if you have already drawn a card or if someone else has taken a turn. Hold it against possible Coup Fourré as the chances are very good for this card.

    If the other team has first play, or you are forced to discard on first play, then watch discards closely; don't just draw to the Roll.

    You often face the situation where your opponent has played Roll and now it is your turn; you hold both a Roll and one or more Hazards. It's aggressive to play the Hazard; Parker Brothers recommends playing the Roll instead. If you have a major Hazard it may be wise to play it, especially if you are fairly well-off in Remedies and Roll cards generally; your opponent may have to Remedy the Hazard, then play a Roll, by which time you will already have played your Roll and some Distance. If you can only play a minor Hazard it's probably unwise; a single Roll will get your opponent moving again after a Stop, while a Speed Limit may not interfere at all with his coming out with a small Distance card.

    Note that regardless of the Hazard played, your opponent may well Coup Fourré, playing Distance immediately and adding points to the insult. Against this risk is the hope of holding the other team to a Shut Out.

    Until you have played some Distance, you face a potential Shut Out yourself. If your opponent has played Distance, you must bend your efforts to breaking Shut Out ahead of every other consideration.

    Keep a small Distance card in hand when waiting to get "moving". This is better than an End of Limit card; you might see two or three Speed Limits played on your team and not be able to move when you get that Roll. Better to discard the End of Limit or a larger Distance card.

Middle Game:

    Never forget to draw before playing. Who knows? The draw may be the card you need.

    Be alert for Hazards played on your team. It's exasperating to miss one's chance for Coup Fourré.

    If you have large Distance in hand, play it at once instead of an uncertain Hazard. If you have only small Distance then the Hazard is more attractive. Of course, if you know your opponent will have trouble with the Hazard then it's a good play.

    Remember that Speed Limit is a weak card; your opponent may still make good progress 50 km at a time. It's generally unwise to play Speed Limit on a "stopped" opponent; he may Coup Fourré with the Right of Way card even if he cannot then play any Distance.

    Constantly be ready to re-evaluate the relative strengths of the cards you hold in light of those you have seen. Play strong Hazards before weak ones; discard worthless cards before useful ones and cards of lesser use before those more likely to be useful.

    Since there are 3 of each major Hazard (perhaps only 2), it is, relatively speaking, fairly likely that you will face each one at least once. So it is wise to keep a full set of Remedies (or corresponding Safeties) at first. However, with each Hazard seen the risk of taking another of the same Hazard falls -- and so does the value of the Remedy.

    If you have corrected a Hazard with a Remedy and have no Roll card, one may play Right of Way normally to get "moving" again and play Distance on the same turn. One forgoes an ordinarily-good chance at Coup Fourré for certain Distance. This is a great way to break a difficult Shut Out.

End of Hand:

    When you near trip completion it is mandatory to take care to go out evenly; going over the trip limit is not allowed. You may want to put together all of the last 200 km in your hand before playing any of it.

    When your opponent is getting ready to go out and you are far from completion you may want to discard Remedies quickly. Your situation is desperate and you will need a lot of Distance to overtake; if you take a Hazard and cannot go at all you may not have lost much.

    Play for fun and play for money imposes different end game strategies. In play for fun, all that matters is exceeding 5000 points; if necessary, exceeding the other team as well. There is no need to take any risks if you can win without them. Playing for money, every point counts and it may be a good gamble to go for the Extension or Coup Fourré.

Extension:

When playing with the possibility of Extension, the decision (when reaching 700 km) whether to go out immediately or call for the Extension is critical. The Extension itself is worth 200 points; there is also the opportunity to score another 300 points' worth of Distance. There is also considerable risk.

Generally, Extension should be used to aggravate one's existing superior position. Lacking overwhelming superiority, Extension may backfire on the caller.

    The safest time to call for Extension is when one is protected against all possible Hazards -- by holding at least one appropriate Remedy and one or more Roll cards, by holding or having played the appropriate Safety, or by exhaustion of that Hazard.

    It may be wiser to call an Extension when one's opponent is already facing an intractable Hazard. Holding, say, two Accident cards and the Driving Ace when several Repairs have already been played places one in a strong position for Extension.

    Be careful to avoid Extension unless one has the needed 300 km in hand unless sufficient cards remain in the draw pile.

    Let us say that Blue has played a total of 300 km and is "stopped" due to a Flat Tire when Red reaches 700 km. Red chooses to extend, hoping for an additional 500 points. Before Red reaches 1000 km, Blue corrects the Hazard and rolls on to 900 km. Red completes the trip and scores 500 more points than he would have had he not called for Extension. However, Blue has scored 600 more than he would have; Red faces a 100-point net loss for his Extension call.

    Having an unplayed Safety in one's hand at the time 700 km is reached raises the stakes. One might dare Extension hoping for Coup Fourré. Don't forget, though, to play the Safety normally just before going out.

    It's not enough merely to have appropriate Remedies in case of Hazard; one must also have Roll cards. For this reason, having the Right of Way card in one's favor is a strong indicator of a good possible Extension; conversely, failure to hold this card may be a good reason to decline.

    Successful Extension is demoralizing to the opposition, so an aggressive strategy here may have a payoff beyond the hand.

    The riskiest time to call Extension is when one's opponent has, so far, been Shut Out. The Shut Out is worth 500 points by itself; it would be a shame to lose that advantage. You should be entirely sure of keeping your opponent "stopped" in this case.

    The strategic points in this section apply generally to the case of Delayed Action. You may be able to complete a trip before the draw pile runs out, yet continue to discard until you can score the additional 300 points. Do so with care only.

