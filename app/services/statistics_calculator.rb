class StatisticsCalculator
  def initialize(teams, matches, current_week)
    @teams = teams
    @matches = matches
    @current_week = current_week
  end

  def render_league_table
    @teams.sort_by! { |team| [-team.points, team.goal_difference, team.goals_scored] }
    table_html = "<table><tr><th>Teams</th><th>PTS</th><th>P</th><th>W</th><th>D</th><th>L</th><th>GD</th><th>#{@current_week}th Week Match Results</th></tr>"
    @teams.each do |team|
      table_html += "<tr><td>#{team.name}</td><td>#{team.points}</td><td>#{team.wins + team.draws + team.losses}</td><td>#{team.wins}</td><td>#{team.draws}</td><td>#{team.losses}</td><td>#{team.goal_difference}</td><td>#{match_results(team)}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end

  def render_championship_predictions
    total_points = @teams.sum(&:points)
    table_html = "<table><tr><th>#{@current_week}th week Predictions of Championship</th><th></th></tr>"
    @teams.each do |team|
      percentage = total_points > 0 ? (team.points.to_f / total_points * 100).round : 0
      percentage = team == @teams.first && @current_week == 8 ? 100 : percentage
      table_html += "<tr><td>#{team.name}</td><td>%#{percentage}</td></tr>"
    end
    table_html += "</table>"
    table_html
  end

  private

  def match_results(team)
    results = ""
    matches_for_week = @matches.select { |match| match.week == @current_week }
    matches_for_week.each do |match|
      if match.home_team == team
        results += "#{match.home_team.name} #{match.home_goals} - #{match.away_goals} #{match.away_team.name}<br>"
      elsif match.away_team == team
        results += "#{match.away_team.name} #{match.away_goals} - #{match.home_goals} #{match.home_team.name}<br>"
      end
    end
    results
  end
end
