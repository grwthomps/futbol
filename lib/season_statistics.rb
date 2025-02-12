module SeasonStatistics

  def filter_games_by_season_helper(season_id)
    filtered_games = []
    @games.each do |game_id, game|
      filtered_games.push(game) if game.season == season_id
    end
    filtered_games
  end

  def filter_game_teams_by_season_helper(season_id)
    @game_teams.find_all do |game|
      @games[game.game_id].season == season_id
    end
  end

  def win_avg_by_season_type(season_id)
    team_ids = @game_teams.map {|team| team.team_id}.uniq

    biggest_hash = {}
    team_ids.each do |team_id|
      biggest_hash[team_id] ||= {postseason: {games: [], win_avg: 0},
                                 regular_season: {games: [], win_avg: 0}}

      filter_games_by_season_helper(season_id).each do |game|
        if game.home_team_id == team_id || game.away_team_id == team_id
          biggest_hash[team_id][:postseason][:games].push(game) if game.type == "Postseason"
          biggest_hash[team_id][:regular_season][:games].push(game) if game.type == "Regular Season"
        end
      end
    end

    biggest_hash.each do |team_id, seasons|
      seasons.each do |season_type, hash_pair|
        win_avg = 0
        hash_pair.each do |key, value|
          if key == :games
            win_avg = (value.find_all do |game|
              (game.away_team_id == team_id && game.home_goals < game.away_goals) ||
              (game.home_team_id == team_id && game.home_goals > game.away_goals)
            end.length.to_f) / value.length
          end
        end
        biggest_hash[team_id][season_type][:win_avg] = win_avg
      end
    end
    biggest_hash
  end

  def biggest_bust(season_id)
    biggest_bust = win_avg_by_season_type(season_id)
    team_with_biggest_bust = nil
    biggest_bust_difference = 0
    biggest_bust.each do |team_id, seasons|
      seasons[:regular_season][:win_avg] = 0 if seasons[:regular_season][:win_avg].nan?
      seasons[:postseason][:win_avg] = 0 if seasons[:postseason][:win_avg].nan?
      difference = seasons[:regular_season][:win_avg] - seasons[:postseason][:win_avg]
      if difference > biggest_bust_difference
        biggest_bust_difference = difference
        team_with_biggest_bust = team_id
      end
    end
    @teams[team_with_biggest_bust].team_name
  end

  def biggest_surprise(season_id)
    biggest_surprise = win_avg_by_season_type(season_id)

    team_with_biggest_surprise = nil
    biggest_surprise_difference = 0
    biggest_surprise.each do |team_id, seasons|
      seasons[:regular_season][:win_avg] = 0 if seasons[:regular_season][:win_avg].nan?
      seasons[:postseason][:win_avg] = 0 if seasons[:postseason][:win_avg].nan?
      difference = seasons[:postseason][:win_avg] - seasons[:regular_season][:win_avg]
      if difference > biggest_surprise_difference
        biggest_surprise_difference = difference
        team_with_biggest_surprise = team_id
      end
    end
    @teams[team_with_biggest_surprise].team_name
  end

  def most_tackles(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)
    games_by_teams = filtered_games.group_by(&:team_id)

    most_tackles_team_id = nil
    most_tackles = 0
    games_by_teams.each do |team_id, games_arr|
      tackles = games_arr.sum {|game| game.tackles}
      if tackles > most_tackles
        most_tackles_team_id = team_id
        most_tackles = tackles
      end
    end
    @teams[most_tackles_team_id].team_name
  end

  def fewest_tackles(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)
    games_by_teams = filtered_games.group_by(&:team_id)

    fewest_tackles_team_id = nil
    fewest_tackles = 100_000
    games_by_teams.each do |team_id, games_arr|
      tackles = games_arr.sum {|game| game.tackles}
      if tackles < fewest_tackles
        fewest_tackles_team_id = team_id
        fewest_tackles = tackles
      end
    end
    @teams[fewest_tackles_team_id].team_name
  end

  def least_accurate_team(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)
    games_by_teams = filtered_games.group_by(&:team_id)

    lowest_ratio_team_id = nil
    lowest_ratio = 10
    games_by_teams.each do |team_id, games_arr|
      shot_ratio = games_arr.sum(&:goals).to_f / games_arr.sum(&:shots)
      if shot_ratio < lowest_ratio
        lowest_ratio_team_id = team_id
        lowest_ratio = shot_ratio
      end
    end
    @teams[lowest_ratio_team_id].team_name
  end

  def most_accurate_team(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)

    highest_ratio_team_id = nil
    highest_ratio = 10
    filtered_games.group_by(&:team_id).each do |team_id, games_arr|
      shot_ratio = games_arr.sum(&:shots).to_f / games_arr.sum(&:goals)
      if shot_ratio < highest_ratio
        highest_ratio_team_id = team_id
        highest_ratio = shot_ratio
      end
    end
    @teams[highest_ratio_team_id].team_name
  end

  def winningest_coach(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)
    most_wins_coach_name = nil
    highest_win_percentage = 0
    filtered_games.group_by(&:head_coach).each do |coach_name, games_arr|
      win_percentage = (games_arr.find_all do |game|
        game.result == "WIN"
      end.length).to_f / games_arr.length
      if win_percentage > highest_win_percentage
        most_wins_coach_name = coach_name
        highest_win_percentage = win_percentage
      end
    end
    most_wins_coach_name
  end

  def worst_coach(season_id)
    filtered_games = filter_game_teams_by_season_helper(season_id)
    fewest_wins_coach_name = nil
    lowest_win_percentage = 100
    filtered_games.group_by(&:head_coach).each do |coach_name, games_arr|
      win_percentage = (games_arr.find_all do |game|
        game.result == "WIN"
      end.length).to_f / games_arr.length
      if win_percentage < lowest_win_percentage
        fewest_wins_coach_name = coach_name
        lowest_win_percentage = win_percentage
      end
    end
    fewest_wins_coach_name
  end
end
