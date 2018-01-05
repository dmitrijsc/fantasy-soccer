SELECT P.team_name, P.name, P.lastname, SUM(IFNULL(S.game_scores, 0)) as scores, SUM(IFNULL(A.score_assists, 0)) as assists
FROM players P
LEFT JOIN
(
	SELECT game_id, team_name, nr, COUNT(1) game_scores FROM scores GROUP BY game_id, team_name, nr

) S ON P.team_name = S.team_name AND P.game_id = S.game_id AND P.nr = S.nr
LEFT JOIN
(
	SELECT game_id, team_name, assist_nr as nr, COUNT(1) score_assists FROM scores_assists GROUP BY game_id, team_name, assist_nr

) A ON P.team_name = A.team_name AND P.game_id = A.game_id AND P.nr = A.nr
GROUP BY P.team_name, P.name, P.lastname
ORDER BY SUM(IFNULL(S.game_scores, 0)) DESC, SUM(IFNULL(A.score_assists, 0)) DESC
LIMIT 10
