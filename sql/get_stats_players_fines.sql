SELECT P.team_name, P.name, P.lastname, COUNT(1) as fines_count
FROM players P
INNER JOIN fines F ON P.game_id = F.game_id AND P.team_name = F.team_name AND P.nr = F.nr
GROUP BY P.team_name, P.name, P.lastname
ORDER BY COUNT(1) DESC
