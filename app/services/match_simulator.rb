class MatchSimulator
# Initialize the match simulator with a reference to the league manager
  def initialize(league_manager)
    @league_manager = league_manager
  end

# Simulate matches for a specific week
  def simulate_matches_for_week(week)
    matches_for_week = @league_manager.matches.select { |match| match.week == week }
    matches_for_week.each do |match|
      simulate_match(match)
    end
  end

  private

# Simulate a match between two teams
  def simulate_match(match)
    home_advantage = 0.1
    home_strength = match.home_team.strength * (1 + home_advantage)
    away_strength = match.away_team.strength

    home_goals = (rand * home_strength).to_i
    away_goals = (rand * away_strength).to_i

    match.home_goals = home_goals
    match.away_goals = away_goals

    update_team_stats(match.home_team, home_goals, away_goals)
    update_team_stats(match.away_team, away_goals, home_goals)
    update_points(match.home_team, match.away_team, home_goals, away_goals)
  end

# Update team statistics after a match
  def update_team_stats(team, goals_scored, goals_conceded)
    team.goals_scored += goals_scored
    team.goals_conceded += goals_conceded
  end

# Update points for teams based on match results
  def update_points(home_team, away_team, home_goals, away_goals)
    if home_goals > away_goals
      home_team.points += 3
      home_team.wins += 1
      away_team.losses += 1
    elsif away_goals > home_goals
      away_team.points += 3
      away_team.wins += 1
      home_team.losses += 1
    else
      home_team.points += 1
      away_team.points += 1
      home_team.draws += 1
      away_team.draws += 1
    end
  end
end
