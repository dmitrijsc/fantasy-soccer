SELECT judge, ROUND(AVG(fines_count * 1.0), 1) avg_fines
FROM
(
	SELECT judge, SUM(CASE WHEN F.event_time IS NULL THEN 0 ELSE 1 END) fines_count
	FROM games G
	LEFT JOIN fines F ON G.id = F.game_id
	GROUP BY G.id, G.judge
)
GROUP BY judge
ORDER BY AVG(fines_count * 1.0) DESC
