
SELECT
	  MAX(nr) as nr
	, name
	, lastname
	, COUNT(base_team) total_games
	, SUM(base_team) base_player
	, SUM((played_to - played_from) / 100 + (CASE WHEN played_to % 100 - played_from % 100 > 0 THEN 1 WHEN played_to % 100 - played_from % 100 = 0 THEN 0 ELSE -1 END)) minutes
	, SUM(scores_count) as scores
	, SUM(scores_assists_count) as assists
	, SUM(yellow_cards) as yellow_cards
	, SUM(red_cards) as red_cards
FROM
(
	SELECT PL.game_id
		, PL.team_name
		, PL.nr
		, PL.name
		, PL.lastname
		, PL.base_team
		, time_from as played_from
		, CASE WHEN IFNULL(GA.game_length, 6000) < time_until THEN IFNULL(GA.game_length, 6000) ELSE IFNULL(GA.game_length, 6000) END as played_to
		, (SELECT COUNT(1) FROM scores F WHERE F.game_id = PL.game_id AND F.team_name = PL.team_name AND F.nr = PL.nr ) as scores_count
		, (SELECT COUNT(1) FROM scores_assists F WHERE F.game_id = PL.game_id AND F.team_name = PL.team_name AND F.assist_nr = PL.nr ) as scores_assists_count
		, (SELECT CASE COUNT(1) WHEN 1 THEN 1 ELSE 0 END FROM fines F WHERE F.game_id = PL.game_id AND F.team_name = PL.team_name AND F.nr = PL.nr ) as yellow_cards
		, (SELECT CASE COUNT(1) WHEN 2 THEN 1 ELSE 0 END FROM fines F WHERE F.game_id = PL.game_id AND F.team_name = PL.team_name AND F.nr = PL.nr ) as red_cards
	FROM
	(
		SELECT P.*, 0 time_from, IFNULL(event_time, 9900) time_until
		FROM players P
		LEFT JOIN changes C ON P.game_id = C.game_id AND P.team_name = C.team_name and P.nr = C.nr1
		WHERE role <> 'V' and base_team = 1
		UNION ALL
		SELECT P.*, IFNULL(event_time, 9900) time_from, 9900 time_until
		FROM players P
		INNER JOIN changes C ON P.game_id = C.game_id AND P.team_name = C.team_name and P.nr = C.nr2
		WHERE role <> 'V' and base_team = 0

	)  PL
	LEFT JOIN
	(
		SELECT id as game_id, CASE WHEN IFNULL(MAX(event_time), 6000) <= 6000 THEN 6000 ELSE MAX(event_time) END game_length
		FROM games G
		LEFT JOIN scores S ON G.id = S.game_id
		GROUP BY G.id

	) GA ON PL.game_id = GA.game_id

) PLG
WHERE LOWER(team_name) = LOWER('{team_name}')
GROUP BY team_name, name, lastname
ORDER BY MAX(nr) ASC
