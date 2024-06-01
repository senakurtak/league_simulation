class LeagueController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:simulate_week, :simulate_all]

  def initialize
    super
    @teams = []
    @matches = []

    team1 = Team.new("Chelsea", 10)
    team2 = Team.new("Arsenal", 8)
    team3 = Team.new("Manchester City", 6)
    team4 = Team.new("Liverpool", 4)

    add_team(team1)
    add_team(team2)
    add_team(team3)
    add_team(team4)

    generate_matches
  end

  def index
    session[:current_week] ||= 0
    @league_table = render_league_table
    @championship_predictions = render_championship_predictions
  end

  def simulate_week
    session[:current_week] += 1
    simulate_matches_for_week(session[:current_week])
    render json: {
      league_table: render_league_table,
      championship_predictions: render_championship_predictions
    }
  end

  def simulate_all
    while session[:current_week] < 4
      session[:current_week] += 1
      simulate_matches_for_week(session[:current_week])
    end
    render json: {
      league_table: render_league_table,
      championship_predictions: render_championship_predictions
    }
  end

  private

  def add_team(team)
    @teams << team
  end

  def generate_matches
    team_pairs = @teams.combination(2).to_a
    team_pairs.each_with_index do |pair, index|
      create_match(pair[0], pair[1], (index % 4) + 1)
      create_match(pair[1], pair[0], (index % 4) + 1)
    end
  end

  def create_match(home_team, away_team, week)
    match = Match.new(home_team, away_team, week)
    @matches << match
    match
  end

  def simulate_matches_for_week(week)
    matches_for_week = @matches.select { |match| match.week == week }
    matches_for_week.each do |match|
      simulate_match(match)
    end
  end

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

  def update_team_stats(team, goals_scored, goals_conceded)
    team.goals_scored += goals_scored
    team.goals_conceded += goals_conceded
  end

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

  def render_league_table
    @teams.sort_by! { |team| [-team.points, team.goal_difference, team.goals_scored] }
    table_html = "<table><tr><th>Teams</th><th>PTS</th><th>P</th><th>W</th><th>D</th><th>L</th><th>GD</th><th>#{session[:current_week]}th Week Match Results</th></tr>"
    @teams.each do |team|
      table_html += "<tr><td>#{team.name}</td><td>#{team.points}</td><td>#{team.wins + team.draws + team.losses}</td><td>#{team.wins}</td><td>#{team.draws}</td><td>#{team.losses}</td><td>#{team.goal_difference}</td><td>#{match_results(team)}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end

  def match_results(team)
    results = ""
    matches_for_week = @matches.select { |match| match.week == session[:current_week] }
    matches_for_week.each do |match|
      if match.home_team == team
        results += "#{match.home_team.name} #{match.home_goals} - #{match.away_goals} #{match.away_team.name}<br>"
      elsif match.away_team == team
        results += "#{match.away_team.name} #{match.away_goals} - #{match.home_goals} #{match.home_team.name}<br>"
      end
    end
    results
  end

  def render_championship_predictions
    total_points = @teams.sum(&:points)
    table_html = "<table><tr><th>#{session[:current_week]}th week Predictions of Championship</th><th></th></tr>"
    @teams.each do |team|
      if total_points > 0
        percentage = (team.points.to_f / total_points * 100).round
      else
        percentage = 0
      end
      table_html += "<tr><td>#{team.name}</td><td>%#{percentage}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end
end
