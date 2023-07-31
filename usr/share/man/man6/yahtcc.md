<summary>Yahtzee clone for Phoenix</summary>
# NAME
    yahtcc - Yahtzee clone for Phoenix

# SYNOPSIS
    **yahtcc**

# DESCRIPTION
**yahtcc** is a clone of the popular dice game "Yahtzee". Players roll a set of
five dice up to three times per round, trying to get the dice to roll in
certain patterns. Each pattern grants a number of points, and the goal of the
game is to achieve the highest number of points.

The main screen shows a scorecard with the available categories and the number
of points already scored or available to score. Locked scores are colored white,
possible scores are colored blue, and possible scores worth 0 points are colored
gray. Below that, the current set of dice is displayed. Locked dice are colored
yellow, while unlocked dice are colored white. The roll cup shows whether
another roll is available. The current total score and number of available rolls
is displayed above the scorecard.

To roll the dice, press the **R** key or click on the roll cup. The unlocked
dice will be rolled fresh, leaving the locked dice in-place. Dice may then be
locked or unlocked by pressing the **1**-**5** keys, or by clicking on any of
the dice. To lock a score, use the arrow keys to select the category to score,
and press **Enter** to score it. Alternatively, double-click on any of the
unscored categories.

# GAMEPLAY
A game of **yahtcc** consists of 13 rounds, with each round having three dice
rolls, and ends when the player selects a pattern to score the current set of
dice on. Between rolls, the player may lock any of the five dice, which will
prevent them from being changed in the next roll. The player may score during
any roll, but they must score after the third roll. Once a pattern is scored, it
cannot be changed later.

Six of the patterns are scored based on the number of dice in the set that match
the number for the score. The score is calculated by summing the values of those
dice. For example, the *Threes* pattern will sum the value of all of the dice
with a value of 3.

Six of the patterns are all-or-nothing based on whether the set of dice contains
dice matching a pattern. If the pattern matches, the category gets the full score; otherwise, it is worth 0 points. The patterns in this category are scored as follows:

- *Three of a Kind*: Matches when any three dice have the same value. Worth
the sum of all dice in the set.
- *Four of a Kind*: Matches when any four dive have the same value. Worth
the sum of all dice in the set.
- *Full House*: Matches when three dice have the same value, and two differently-valued dice are equal. Worth 25 points.
- *Small Straight*: Matches when four dice have sequential values (i.e. 1-2-3-4,
2-3-4-5, 3-4-5-6). Worth 30 points.
- *Large Straight*: Matches when five dice have sequential values (i.e.
1-2-3-4-5, 2-3-4-5-6). Worth 40 points.
- *Yahtzee*: Matches when all five dice have the same value. Worth 50 points.

The last pattern, *Chance*, is a wildcard pattern that is always worth points.
Its value is equal to the sum of the values of all dice.

Two bonuses can be triggered during the game. The *Bonus* score on the left is
activated when the sum of all of the numbered scores is greater than or equal to
63, which corresponds to at least 3 dice in each category. When activated, it is
worth 35 points. The *Yahtzee Bonus* score on the right is automatically
activated when all five dice rolled have the same value and the *Yahtzee*
category has been scored with 50 points. It is worth 100 points.

Once all 13 categories have been scored, the game ends, and the final score is
simply the sum of all points awarded in each category. The final score is
printed to the console after the game ends.

# AUTHORS
YahtCC was written by JackMacWindows in 2020, and ported to Phoenix in 2022. It is licensed under the GPL license.

*Yahtzee* is a registered trademark of Hasbro, Inc.
