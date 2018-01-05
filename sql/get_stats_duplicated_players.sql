SELECT name, lastname, COUNT(DISTINCT nr) matches, min(team_name) team1, max(team_name) team2
FROM players
GROUP BY name, lastname
HAVING COUNT(DISTINCT nr) > 1
