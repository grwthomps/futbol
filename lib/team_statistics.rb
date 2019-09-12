module TeamStatistics

  def team_info(team_id)
    found_team = @teams.fetch(team_id.to_i)
    {"team_id" => found_team.team_id.to_s,
      "franchise_id" => found_team.franchise_id.to_s,
      "team_name" => found_team.team_name,
      "abbreviation" => found_team.abbreviation,
      "link" => found_team.link}
  end

  def filter_games_by_team(team_id)
    filtered_games = []
    @games.each do |game_id, game|
      filtered_games.push(game) if game.home_team_id == team_id || game.away_team_id == team_id
    end
    filtered_games
  end

  def season_helper(team_id)
    games_by_season = filter_games_by_team(team_id).group_by(&:season)

    season_win_avg = Hash.new(0)
    games_by_season.each do |season, games|
      home_wins = games.find_all do |game|
        game.home_team_id == team_id && game.home_goals > game.away_goals
      end
      away_wins = games.find_all do |game|
        game.away_team_id == team_id && game.home_goals < game.away_goals
      end
      season_win_avg[season] = ((home_wins.length.to_f + away_wins.length) / games.length).round(2)
    end
    season_win_avg
  end

  def best_season(team_id)
    season_win_avg ||= season_helper(team_id.to_i)
    season_win_avg.key(season_win_avg.values.max_by { |value| value})
  end

  def worst_season(team_id)
    season_win_avg ||= season_helper(team_id.to_i)
    season_win_avg.key(season_win_avg.values.min_by { |value| value})
  end

  def average_win_percentage(team_id)
    filtered_games = filter_games_by_team(team_id.to_i)
    wins = filtered_games.find_all do |game|
      (game.away_team_id == team_id.to_i && game.home_goals < game.away_goals) ||
      (game.home_team_id == team_id.to_i && game.home_goals > game.away_goals)
    end
    (wins.length.to_f / filtered_games.length).round(2)
  end

  def most_goals_scored(team_id)
    game_teams.find_all do |game_team|
      game_team.team_id == team_id.to_i
    end.max_by(&:goals).goals
  end

  def fewest_goals_scored(team_id)
    game_teams.find_all do |game_team|
      game_team.team_id == team_id.to_i
    end.min_by(&:goals).goals
  end

  def favorite_opponent(team_id)
    head_to_head(team_id).max_by {|team_name, win_average| win_average}[0]
  end

  def rival(team_id)
    head_to_head(team_id).min_by {|team_name, win_average| win_average}[0]
  end

  def biggest_team_blowout(team_id)
    wins = filter_games_by_team(team_id.to_i).find_all do |game|
      (game.away_team_id == team_id.to_i && game.home_goals < game.away_goals) ||
      (game.home_team_id == team_id.to_i && game.home_goals > game.away_goals)
    end

    biggest_blowout = 0
    wins.each do |win|
      biggest_blowout = (win.home_goals - win.away_goals).abs if biggest_blowout < (win.home_goals - win.away_goals).abs
    end
    biggest_blowout.to_i
  end

  def worst_loss(team_id)
    losses = filter_games_by_team(team_id.to_i).find_all do |game|
      (game.away_team_id == team_id.to_i && game.home_goals > game.away_goals) ||
      (game.home_team_id == team_id.to_i && game.home_goals < game.away_goals)
    end

    worst_loss = 0
    losses.each do |loss|
      worst_loss = (loss.home_goals - loss.away_goals).abs if worst_loss < (loss.home_goals - loss.away_goals).abs
    end
    worst_loss.to_i
  end

  def head_to_head(team_id)
    filtered_games = []
    opponents = Hash.new(0)
    head_averages = Hash.new(0)
    @games.each do |game_id, game|
      filtered_games.push(game) if game.home_team_id == team_id.to_i || game.away_team_id == team_id.to_i
      opponents_home = filtered_games.group_by(&:home_team_id)
      opponents_away = filtered_games.group_by(&:away_team_id)
      opponents = opponents_home.merge(opponents_away) do |team_id_m, home_value, away_value|
        home_value + away_value
      end
      opponents.each do |opp_team_id, games|
        win_average = games.find_all do |game_f|
          (game_f.away_team_id == team_id.to_i && game_f.home_goals < game_f.away_goals) ||
          (game_f.home_team_id == team_id.to_i && game_f.home_goals > game_f.away_goals)
        end.length.to_f / games.length
        head_averages[@teams[opp_team_id].team_name] = win_average.round(2)
      end
    end
    head_averages.delete(@teams[team_id.to_i].team_name)
    head_averages
  end

  def seasonal_summary(team_id)
    games_by_season = filter_games_by_team(team_id.to_i).group_by(&:season)
    games_by_type = {}
    games_by_season.each do |season_id, games_arr|
      random_hash = games_arr.group_by(&:type)
      games_by_type[season_id] = random_hash
    end

    season_summary = {}
    games_by_type.each do |season_id, seasons_hash|
      season_summary[season_id] ||= {}
      seasons_hash.each do |season_type, games_arr|
        season_type = :postseason if season_type == 'Postseason'
        season_type = :regular_season if season_type == 'Regular Season'
        season_summary[season_id][season_type] ||= {}
        win_avg = (games_arr.find_all do |game|
          (game.away_team_id == team_id.to_i && game.home_goals < game.away_goals) ||
          (game.home_team_id == team_id.to_i && game.home_goals > game.away_goals)
        end.length.to_f) / games_arr.length
        season_summary[season_id][season_type][:win_percentage] = win_avg.round(2)

        total_goals_s = 0
        total_goals_a = 0
        games_arr.each do |game|
          if game.home_team_id == team_id.to_i
            total_goals_s += game.home_goals
            total_goals_a += game.away_goals
          elsif game.away_team_id == team_id.to_i
            total_goals_a += game.home_goals
            total_goals_s += game.away_goals
          end
        end
        season_summary[season_id][season_type][:total_goals_scored] = total_goals_s.to_i
        season_summary[season_id][season_type][:total_goals_against] = total_goals_a.to_i
        season_summary[season_id][season_type][:average_goals_scored] = (total_goals_s.to_f / games_arr.length).round(2)
        season_summary[season_id][season_type][:average_goals_against] = (total_goals_a.to_f / games_arr.length).round(2)
      end
    end

    empty_summary = {win_percentage: 0.0, total_goals_scored: 0, total_goals_against: 0, average_goals_scored: 0.0, average_goals_against: 0.0}
    all_seasons = @games.inject([]) {|seasons, (_, game)| seasons << game.season}.uniq
    all_seasons.each do |season|
      season_summary[season][:postseason] = empty_summary if !season_summary[season].has_key?(:postseason)
      season_summary[season][:regular_season] = empty_summary if !season_summary[season].has_key?(:regular_season)
    end
    season_summary
  end
end
