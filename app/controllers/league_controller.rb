class LeagueController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:simulate_week, :simulate_all]

  # Initialize the league and matches when the controller is created
  def initialize
    super
    initialize_league
  end

  # Display the initial league table and championship predictions
  def index
    session[:current_week] ||= 0
    @league_table = render_league_table
    @championship_predictions = render_championship_predictions
  end

  # Simulate matches for one week and update the league table
  def simulate_week
    if session[:current_week] < 8
      session[:current_week] += 1
    else
      reset_league
      session[:current_week] = 1
    end
    simulate_matches_for_week(session[:current_week])
    render json: {
      league_table: render_league_table,
      championship_predictions: render_championship_predictions
    }
  end

  # Simulate matches for all weeks (8 week) until the end of the season
  def simulate_all
    while session[:current_week] < 8
      session[:current_week] += 1
      simulate_matches_for_week(session[:current_week])
    end
    if session[:current_week] >= 8
      reset_league
      session[:current_week] = 1
    end
    render json: {
      league_table: render_league_table,
      championship_predictions: render_championship_predictions
    }
  end

  private

  # Initialize the league with teams and generate matches
  def initialize_league
    @teams = []
    @matches = []

    # Create teams
    team1 = Team.new("Chelsea", 10)
    team2 = Team.new("Arsenal", 8)
    team3 = Team.new("Manchester City", 6)
    team4 = Team.new("Liverpool", 4)
    team5 = Team.new("Everton", 2)
    team6 = Team.new("Newcastle", 3)
    team7 = Team.new("Sheffield Utd", 6)
    team8 = Team.new("Bournemouth", 4)

    # Add teams to the league
    add_team(team1)
    add_team(team2)
    add_team(team3)
    add_team(team4)
    add_team(team5)
    add_team(team6)
    add_team(team7)
    add_team(team8)

    # Generate the schedule for the matches
    generate_matches
  end

  # Reset the league to start a new season
  def reset_league
    @teams.each do |team|
      team.points = 0
      team.goals_scored = 0
      team.goals_conceded = 0
      team.wins = 0
      team.draws = 0
      team.losses = 0
    end
    @matches = []
    generate_matches
  end

  # Add a team to the league
  def add_team(team)
    @teams << team
  end

  # Generate matches for the season
  def generate_matches
    team_pairs = @teams.combination(2).to_a
    team_pairs.each_with_index do |pair, index|
      create_match(pair[0], pair[1], (index / 4) + 1) # Schedule two matches per week
    end
  end

  # Create a match for a given week
  def create_match(home_team, away_team, week)
    match = Match.new(home_team, away_team, week)
    @matches << match
    match
  end

  # Simulate matches for a specific week
  def simulate_matches_for_week(week)
    matches_for_week = @matches.select { |match| match.week == week }
    matches_for_week.each do |match|
      simulate_match(match)
    end
  end

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

  # Render the league table as HTML
  def render_league_table
    @teams.sort_by! { |team| [-team.points, team.goal_difference, team.goals_scored] }
    table_html = "<table><tr><th>Teams</th><th>PTS</th><th>P</th><th>W</th><th>D</th><th>L</th><th>GD</th><th>#{session[:current_week]}th Week Match Results</th></tr>"
    @teams.each do |team|
      table_html += "<tr><td>#{team.name}</td><td>#{team.points}</td><td>#{team.wins + team.draws + team.losses}</td><td>#{team.wins}</td><td>#{team.draws}</td><td>#{team.losses}</td><td>#{team.goal_difference}</td><td>#{match_results(team)}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end

  # Display match results for a team
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

  # Render championship predictions as HTML
  def render_championship_predictions
    total_points = @teams.sum(&:points)
    table_html = "<table><tr><th>#{session[:current_week]}th week Predictions of Championship</th><th></th></tr>"
    @teams.each do |team|
      if total_points > 0
        percentage = (team.points.to_f / total_points * 100).round
      else
        percentage = 0
      end
      if session[:current_week] == 8
        percentage = team == @teams.first ? 100 : 0
      end
      table_html += "<tr><td>#{team.name}</td><td>%#{percentage}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end
end
