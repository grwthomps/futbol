require './test/test_helper'
require './lib/stat_tracker'

class StatTrackerTest < Minitest::Test

  def setup
    game_path = './data/games.csv'
    team_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'
    @locations = {
      games: game_path,
      teams: team_path,
      game_teams: game_teams_path
    }
    @stat_tracker = StatTracker.from_csv(@locations)
  end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_can_show_highest_total_score
    assert_equal 11, @stat_tracker.highest_total_score
  end

  def test_it_can_show_lowest_total_score
    assert_equal 0, @stat_tracker.lowest_total_score
  end

  def test_biggest_blowout
    assert_equal 8, @stat_tracker.biggest_blowout
  end

  def test_percentage_home_wins
    assert_equal 0.44, @stat_tracker.percentage_home_wins
  end

  def test_percentage_visitor_wins
    assert_equal 0.36, @stat_tracker.percentage_visitor_wins
  end

  def test_percentage_ties
    assert_equal 0.20, @stat_tracker.percentage_ties
  end

  def test_count_of_games_by_season
    expected = {
      "20122013"=>806,
      "20162017"=>1317,
      "20142015"=>1319,
      "20152016"=>1321,
      "20132014"=>1323,
      "20172018"=>1355
    }
    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_average_goals_per_game
    assert_equal 4.22, @stat_tracker.average_goals_per_game
  end

  def test_average_goals_by_season
    expected = {
      "20122013"=>4.12,
      "20162017"=>4.23,
      "20142015"=>4.14,
      "20152016"=>4.16,
      "20132014"=>4.19,
      "20172018"=>4.44
    }
    assert_equal expected, @stat_tracker.average_goals_by_season
  end

  def test_count_of_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_best_offense
    assert_equal "Reign FC", @stat_tracker.best_offense
  end

  def test_worst_offense
    assert_equal "Utah Royals FC", @stat_tracker.worst_offense
  end

  def test_best_defense
    assert_equal "FC Cincinnati", @stat_tracker.best_defense
  end

  def test_worst_defense
    assert_equal "Columbus Crew SC", @stat_tracker.worst_defense
  end

  def test_highest_scoring_visitor
    assert_equal "FC Dallas", @stat_tracker.highest_scoring_visitor
  end

  def test_highest_scoring_home_team
    assert_equal "Reign FC", @stat_tracker.highest_scoring_home_team
  end

  def test_lowest_scoring_visitor
    assert_equal "San Jose Earthquakes", @stat_tracker.lowest_scoring_visitor
  end

  def test_lowest_scoring_home_team
    assert_equal "Utah Royals FC", @stat_tracker.lowest_scoring_home_team
  end

  def test_winningest_team
    assert_equal "Reign FC", @stat_tracker.winningest_team
  end

  def test_best_fans
    assert_equal "San Jose Earthquakes", @stat_tracker.best_fans
  end

  def test_worst_fans
    assert_equal ["Houston Dynamo", "Utah Royals FC"], @stat_tracker.worst_fans
  end

  def test_team_info
    expected = {
      "team_id" => "18",
      "franchise_id" => "34",
      "team_name" => "Minnesota United FC",
      "abbreviation" => "MIN",
      "link" => "/api/v1/teams/18"
    }

    assert_equal expected, @stat_tracker.team_info("18")
  end

  def test_best_season
    assert_equal "20132014", @stat_tracker.best_season("6")
  end

  def test_worst_season
    assert_equal "20142015", @stat_tracker.worst_season("6")
  end

  def test_average_win_percentage
    assert_equal 0.49, @stat_tracker.average_win_percentage("6")
  end

  def test_most_goals_scored
    assert_equal 7, @stat_tracker.most_goals_scored("18")
  end

  def test_fewest_goals_scored
    assert_equal 0, @stat_tracker.fewest_goals_scored("18")
  end

  def test_favorite_opponent
    assert_equal "DC United", @stat_tracker.favorite_opponent("18")
  end

  def test_rival
    assert_equal "Houston Dash", @stat_tracker.rival("18")
  end

  def test_biggest_team_blowout
    assert_equal 5, @stat_tracker.biggest_team_blowout("18")
  end

  def test_worst_loss
    assert_equal 4, @stat_tracker.worst_loss("18")
  end

  def test_head_to_head
    expected = {
     "Atlanta United"=>0.5,
     "Chicago Fire"=>0.3,
     "FC Cincinnati"=>0.39,
     "DC United"=>0.8,
     "FC Dallas"=>0.4,
     "Houston Dynamo"=>0.4,
     "Sporting Kansas City"=>0.25,
     "LA Galaxy"=>0.29,
     "Los Angeles FC"=>0.44,
     "Montreal Impact"=>0.33,
     "New England Revolution"=>0.47,
     "New York City FC"=>0.6,
     "New York Red Bulls"=>0.4,
     "Orlando City SC"=>0.37,
     "Portland Timbers"=>0.3,
     "Philadelphia Union"=>0.44,
     "Real Salt Lake"=>0.42,
     "San Jose Earthquakes"=>0.33,
     "Seattle Sounders FC"=>0.5,
     "Toronto FC"=>0.33,
     "Vancouver Whitecaps FC"=>0.44,
     "Chicago Red Stars"=>0.48,
     "Houston Dash"=>0.1,
     "North Carolina Courage"=>0.2,
     "Orlando Pride"=>0.47,
     "Portland Thorns FC"=>0.45,
     "Reign FC"=>0.33,
     "Sky Blue FC"=>0.3,
     "Utah Royals FC"=>0.6,
     "Washington Spirit FC"=>0.67,
     "Columbus Crew SC"=>0.5
    }

    assert_equal expected, @stat_tracker.head_to_head("18")
  end

  def test_seasonal_summary
    expected = {"20162017"=>
        {:postseason=>
          {:win_percentage=>0.59,
           :total_goals_scored=>48,
           :total_goals_against=>40,
           :average_goals_scored=>2.18,
           :average_goals_against=>1.82},
         :regular_season=>
          {:win_percentage=>0.38,
           :total_goals_scored=>180,
           :total_goals_against=>170,
           :average_goals_scored=>2.2,
           :average_goals_against=>2.07}},
       "20172018"=>
        {:postseason=>
          {:win_percentage=>0.54,
           :total_goals_scored=>29,
           :total_goals_against=>28,
           :average_goals_scored=>2.23,
           :average_goals_against=>2.15},
         :regular_season=>
          {:win_percentage=>0.44,
           :total_goals_scored=>187,
           :total_goals_against=>162,
           :average_goals_scored=>2.28,
           :average_goals_against=>1.98}},
       "20132014"=>
        {:postseason=>
          {:win_percentage=>0.0,
           :total_goals_scored=>0,
           :total_goals_against=>0,
           :average_goals_scored=>0.0,
           :average_goals_against=>0.0},
         :regular_season=>
          {:win_percentage=>0.38,
           :total_goals_scored=>166,
           :total_goals_against=>177,
           :average_goals_scored=>2.02,
           :average_goals_against=>2.16}},
       "20122013"=>
        {:postseason=>
          {:win_percentage=>0.0,
           :total_goals_scored=>0,
           :total_goals_against=>0,
           :average_goals_scored=>0.0,
           :average_goals_against=>0.0},
         :regular_season=>
          {:win_percentage=>0.25,
           :total_goals_scored=>85,
           :total_goals_against=>103,
           :average_goals_scored=>1.77,
           :average_goals_against=>2.15}},
       "20142015"=>
        {:postseason=>
          {:win_percentage=>0.67,
           :total_goals_scored=>17,
           :total_goals_against=>13,
           :average_goals_scored=>2.83,
           :average_goals_against=>2.17},
         :regular_season=>
          {:win_percentage=>0.5,
           :total_goals_scored=>186,
           :total_goals_against=>162,
           :average_goals_scored=>2.27,
           :average_goals_against=>1.98}},
       "20152016"=>
        {:postseason=>
          {:win_percentage=>0.36,
           :total_goals_scored=>25,
           :total_goals_against=>33,
           :average_goals_scored=>1.79,
           :average_goals_against=>2.36},
         :regular_season=>
          {:win_percentage=>0.45,
           :total_goals_scored=>178,
           :total_goals_against=>159,
           :average_goals_scored=>2.17,
           :average_goals_against=>1.94}}}

    assert_equal expected, @stat_tracker.seasonal_summary("18")
  end

  def test_biggest_bust
    assert_equal "Montreal Impact", @stat_tracker.biggest_bust("20132014")
    assert_equal "Sporting Kansas City", @stat_tracker.biggest_bust("20142015")
  end

  def test_biggest_surprise
    assert_equal "FC Cincinnati", @stat_tracker.biggest_surprise("20132014")
    assert_equal "Minnesota United FC", @stat_tracker.biggest_surprise("20142015")
  end

  def test_most_tackles
    assert_equal "FC Cincinnati", @stat_tracker.most_tackles("20132014")
    assert_equal "Seattle Sounders FC", @stat_tracker.most_tackles("20142015")
  end

  def test_fewest_tackles
    assert_equal "Orlando City SC", @stat_tracker.fewest_tackles("20142015")
    assert_equal "Atlanta United", @stat_tracker.fewest_tackles("20132014")
  end

  def test_least_accurate_team
    assert_equal "New York City FC", @stat_tracker.least_accurate_team("20132014")
    assert_equal "Columbus Crew SC", @stat_tracker.least_accurate_team("20142015")
  end

  def test_most_accurate_team
    assert_equal "Real Salt Lake", @stat_tracker.most_accurate_team("20132014")
    assert_equal "Toronto FC", @stat_tracker.most_accurate_team("20142015")
  end

  def test_winningest_coach
    assert_equal "Claude Julien", @stat_tracker.winningest_coach("20132014")
    assert_equal "Alain Vigneault", @stat_tracker.winningest_coach("20142015")
  end

  def test_worst_coach
    assert_equal "Peter Laviolette", @stat_tracker.worst_coach("20132014")
    assert_equal "Ted Nolan", @stat_tracker.worst_coach("20142015")
  end

end
