class LeagueController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:simulate_week]
  def initialize
    super
    @teams = []
    @matches = []

    team1 = Team.new("Team A", 10)
    team2 = Team.new("Team B", 8)
    team3 = Team.new("Team C", 6)
    team4 = Team.new("Team D", 4)

    add_team(team1)
    add_team(team2)
    add_team(team3)
    add_team(team4)

    4.times do |week|
      create_match(team1, team2, week + 1)
      create_match(team3, team4, week + 1)
      create_match(team1, team3, week + 1)
      create_match(team2, team4, week + 1)
    end
  end

  def index
    @league_table = render_league_table
  end

  def simulate_week
    @matches.each do |match|
      simulate_match(match)
    end
    @league_table = render_league_table
    puts "Simulate week called"  # Bu satırı ekleyin
    render plain: @league_table
  end
  

  private

  def add_team(team)
    @teams << team
  end

  def create_match(home_team, away_team, week)
    match = Match.new(home_team, away_team, week)
    @matches << match
    match
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
    elsif away_goals > home_goals
      away_team.points += 3
    else
      home_team.points += 1
      away_team.points += 1
    end
  end

  def render_league_table
    @teams.sort_by! { |team| [-team.points, team.goals_scored - team.goals_conceded, team.goals_scored] }
    table_html = "<table><tr><th>Team</th><th>Points</th><th>Goals Scored</th><th>Goals Conceded sena-logs vol 2</th></tr>"
    @teams.each do |team|
      table_html += "<tr><td>#{team.name}</td><td>#{team.points}</td><td>#{team.goals_scored}</td><td>#{team.goals_conceded}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end
end
