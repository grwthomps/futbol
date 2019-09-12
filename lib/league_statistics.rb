module LeagueStatistics

  def count_of_teams
    @teams.length
  end

  def goal_avg_helper
    games_by_team = @game_teams.group_by(&:team_id)
    goal_avg_by_team = {}
    games_by_team.each do |team_id, games_arr|
      total_goals = games_arr.sum(&:goals)
      goal_avg_by_team[team_id] = (total_goals.to_f / games_arr.length).round(2)
    end
    goal_avg_by_team
  end

  def goal_avg_by_hoa_helper(hoa)
    games_by_team = @game_teams.group_by(&:team_id)
    goal_avg_by_team = {}
    games_by_team.each do |team_id, games_arr|
      away_games_goals = games_arr.find_all do |game|
        game.hoa == hoa
      end.sum(&:goals)
      goal_avg_by_team[team_id] = (away_games_goals.to_f / games_arr.length).round(2)
    end
    goal_avg_by_team
  end

  def best_offense
    goal_avg_by_team ||= goal_avg_helper
    found_team_id = goal_avg_by_team.key(goal_avg_by_team.values.max_by { |value| value})
    @teams[found_team_id].team_name
  end

  def worst_offense
    goal_avg_by_team ||= goal_avg_helper
    found_team_id = goal_avg_by_team.key(goal_avg_by_team.values.min_by { |value| value})
    @teams[found_team_id].team_name
  end

  def defense_helper
    home_teams = {}
    @games.each_value do |game|
      if !home_teams.has_key?(game.home_team_id)
        home_teams[game.home_team_id] = [game.away_goals]
      else
        home_teams[game.home_team_id].push(game.away_goals)
      end
    end

    away_teams = {}
    @games.each_value do |game|
      if !away_teams.has_key?(game.away_team_id)
        away_teams[game.away_team_id] = [game.home_goals]
      else
        away_teams[game.away_team_id].push(game.home_goals)
      end
    end
    teams = home_teams.merge(away_teams) { |team_id, home_team_val, away_team_val| home_team_val + away_team_val}

    goal_avg_by_team = {}
    teams.each do |team_id, goals_arr|
      total_goals = goals_arr.sum
      goal_avg_by_team[team_id] = (total_goals.to_f / goals_arr.length).round(2)
    end
    goal_avg_by_team
  end

  def best_defense
    goal_avg_by_team ||= defense_helper
    best_defense = goal_avg_by_team.key(goal_avg_by_team.values.min_by { |value| value})
    @teams[best_defense].team_name
  end

  def worst_defense
    goal_avg_by_team ||= defense_helper
    worst_defense = goal_avg_by_team.key(goal_avg_by_team.values.max_by { |value| value})
    @teams[worst_defense].team_name
  end

  def highest_scoring_visitor
    goal_avg_by_team ||= goal_avg_by_hoa_helper("away")
    highest_team_id = goal_avg_by_team.key(goal_avg_by_team.values.max_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def highest_scoring_home_team
    goal_avg_by_team ||= goal_avg_by_hoa_helper("home")
    highest_team_id = goal_avg_by_team.key(goal_avg_by_team.values.max_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def lowest_scoring_visitor
    goal_avg_by_team ||= goal_avg_by_hoa_helper("away")
    highest_team_id = goal_avg_by_team.key(goal_avg_by_team.values.min_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def lowest_scoring_home_team
    goal_avg_by_team ||= goal_avg_by_hoa_helper("home")
    highest_team_id = goal_avg_by_team.key(goal_avg_by_team.values.min_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def winningest_team
    games_by_team = @game_teams.group_by(&:team_id)
    win_avg_by_team = {}
    games_by_team.each do |team_id, games_arr|
      won_games = games_arr.find_all do |game|
        game.result == "WIN"
      end.length
      win_avg_by_team[team_id] = (won_games.to_f / games_arr.length).round(2)
    end
    highest_team_id = win_avg_by_team.key(win_avg_by_team.values.max_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def best_fans
    games_by_team = @game_teams.group_by(&:team_id)
    avg_by_team = {}
    games_by_team.each do |team_id, games_arr|
      home_won_games = games_arr.find_all do |game|
        game.result == "WIN" && game.hoa == "home"
      end.length

      away_won_games = games_arr.find_all do |game|
        game.result == "WIN" && game.hoa == "away"
      end.length

      home = home_won_games.to_f / games_arr.length
      away = away_won_games.to_f / games_arr.length
      avg_by_team[team_id] = (home - away).round(2)
    end
    highest_team_id = avg_by_team.key(avg_by_team.values.max_by { |value| value})
    @teams[highest_team_id].team_name
  end

  def worst_fans
    games_by_team = @game_teams.group_by(&:team_id)
    worst_fans_teams = []
    games_by_team.each do |team_id, games_arr|
      home_won_games = games_arr.find_all do |game|
        game.result == "WIN" && game.hoa == "home"
      end.length

      away_won_games = games_arr.find_all do |game|
        game.result == "WIN" && game.hoa == "away"
      end.length

      worst_fans_teams.push(team_id) if away_won_games > home_won_games
    end

    worst_fans_teams.map do |worst_team|
      @teams[worst_team].team_name
    end
  end
end
