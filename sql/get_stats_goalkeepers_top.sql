
SELECT team_name, name, lastname, ROUND(AVG(misses * 1.0), 1) mean_misses
FROM
(
	SELECT V.game_id, V.team_name, V.name, V.lastname, SUM(CASE WHEN S.event_time IS NULL THEN 0 ELSE 1 END) misses
	FROM
	(
		SELECT P.*, 0 time_from, IFNULL(event_time, 9900) time_until
		FROM players P
		LEFT JOIN changes C ON P.game_id = C.game_id AND P.team_name = C.team_name and P.nr = C.nr1
		WHERE role = 'V' and base_team = 1
		UNION ALL
		SELECT P.*, IFNULL(event_time, 9900) time_from, 9900 time_until
		FROM players P
		INNER JOIN changes C ON P.game_id = C.game_id AND P.team_name = C.team_name and P.nr = C.nr2
		WHERE role = 'V' and base_team = 0
	) V
	LEFT JOIN scores S ON S.game_id = V.game_id AND S.team_name <> V.team_name AND S.event_time >= time_from AND S.event_time < time_until
	GROUP BY V.game_id, V.team_name, V.name, V.lastname
) Z
GROUP BY team_name, name, lastname
ORDER BY AVG(misses * 1.0) ASC
LIMIT 5
