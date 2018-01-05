SELECT
      max(nr) as nr
	, name
	, lastname
	, SUM(base_team) base_player
	, COUNT(1) total_games
	, SUM(played_to - played_from) / 100 + (CASE WHEN played_to % 100 - played_from % 100 > 0 THEN 1 WHEN played_to % 100 - played_from % 100 = 0 THEN 0 ELSE -1 END) minutes
	, ROUND(AVG(misses * 1.0), 1) mean_misses
FROM
(
	SELECT V.game_id, V.team_name, V.nr, V.name, V.lastname, V.base_team
		, SUM(CASE WHEN S.event_time IS NULL THEN 0 ELSE 1 END) misses
		, time_from as played_from
		, CASE WHEN IFNULL(GA.game_length, 6000) < time_until THEN IFNULL(GA.game_length, 6000) ELSE IFNULL(GA.game_length, 6000) END as played_to
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
	LEFT JOIN
	(
		SELECT id as game_id, CASE WHEN IFNULL(MAX(event_time), 6000) <= 6000 THEN 6000 ELSE MAX(event_time) END game_length
		FROM games G
		LEFT JOIN scores S ON G.id = S.game_id
		GROUP BY G.id

	) GA ON V.game_id = GA.game_id
	GROUP BY V.game_id, V.team_name, V.name, V.lastname
) Z
WHERE LOWER(team_name) = LOWER('{team_name}')
GROUP BY team_name, name, lastname
