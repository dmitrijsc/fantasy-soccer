SELECT * FROM
(
  SELECT

    A.team_name,

    SUM(CASE
        WHEN (A.max_time <= 6000 AND B.max_time <= 6000) AND (A.total_score > B.total_score) THEN 5
        WHEN (A.max_time > 6000 OR B.max_time > 6000) AND (A.total_score > B.total_score) THEN 3
        WHEN (A.max_time <= 6000 AND B.max_time <= 6000) AND (A.total_score < B.total_score) THEN 1
        WHEN (A.max_time > 6000 OR B.max_time > 6000) AND (A.total_score < B.total_score) THEN 2
        ELSE 0
    END)

    AS total_points,

    SUM(CASE
        WHEN (A.max_time <= 6000 AND B.max_time <= 6000) AND (A.total_score > B.total_score) THEN 1
        ELSE 0
    END)

    AS wins_first_60,

    SUM(CASE
        WHEN (A.max_time <= 6000 AND B.max_time <= 6000) AND (A.total_score < B.total_score) THEN 1
        ELSE 0
    END)

    AS loses_first_60,

    SUM(CASE
        WHEN (A.max_time > 6000 OR B.max_time > 6000) AND (A.total_score > B.total_score) THEN 1
        ELSE 0
    END)

    AS wins_overtime,

    SUM(CASE
        WHEN (A.max_time > 6000 OR B.max_time > 6000) AND (A.total_score < B.total_score) THEN 1
        ELSE 0
    END)

    AS loses_overtime,

    SUM(A.total_score) total_scores,
    SUM(B.total_score) total_misses

  FROM
  (
    SELECT T.game_id, T.team_name, SUM(CASE WHEN event_time IS NULL THEN 0 ELSE 1 END) total_score, MAX(IFNULL(event_time, 0)) as max_time
    FROM
    (
    	SELECT id as game_id, team1 team_name FROM games
    	UNION ALL
    	SELECT id as game_id, team2 as team_name FROM games
    ) T
    LEFT JOIN scores S ON T.game_id = S.game_id AND T.team_name = S.team_name
    GROUP BY T.game_id, T.team_name

  ) A INNER JOIN
  (
  	SELECT T.game_id, T.team_name, SUM(CASE WHEN event_time IS NULL THEN 0 ELSE 1 END) total_score, MAX(IFNULL(event_time, 0)) as max_time
    FROM
    (
    	SELECT id as game_id, team1 team_name FROM games
    	UNION ALL
    	SELECT id as game_id, team2 as team_name FROM games
    ) T
    LEFT JOIN scores S ON T.game_id = S.game_id AND T.team_name = S.team_name
    GROUP BY T.game_id, T.team_name
  ) B
  ON A.game_id = B.game_id AND A.team_name <> B.team_name
  GROUP BY A.team_name
) Z
ORDER BY total_points DESC
