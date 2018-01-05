SELECT P.team_name, SUM(CASE WHEN C.event_time IS NULL THEN 0 ELSE 1 END) replaces
FROM players P
LEFT JOIN changes C ON P.game_id = C.game_id AND P.team_name = C.team_name and P.nr = C.nr1
WHERE base_team = 1
GROUP BY P.team_name
ORDER BY SUM(CASE WHEN C.event_time IS NULL THEN 0 ELSE 1 END) DESC
