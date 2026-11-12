SELECT 
    s.sum_ner,
    SUM(t.too_tolgoi) AS niit_mal
FROM sum_duureg s
JOIN bag b ON s.sum_id = b.sum_id
JOIN orkh o ON b.bag_id = o.bag_id
JOIN toollogo t ON o.orkh_id = t.orkh_id
WHERE t.toollogo_on = 2024
GROUP BY s.sum_ner
ORDER BY niit_mal DESC;

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    SUM(bm.jin_kg) AS niit_nooluur_kg,
    SUM(bm.mor_dun) AS niit_orlogo_tug
FROM orkh o
JOIN nooluur_borluulalt nb ON o.orkh_id = nb.orkh_id
JOIN borluulalt_mor bm ON nb.borluulalt_id = bm.borluulalt_id
WHERE EXTRACT(YEAR FROM nb.ognoo) = 2024
GROUP BY o.orkh_kod, o.ovoo_ner
ORDER BY niit_nooluur_kg DESC
LIMIT 5;

SELECT 
    bm.ongots,
    COUNT(*) AS moriin_too,
    SUM(bm.jin_kg) AS niit_jin_kg,
    ROUND(AVG(bm.negj_une), 2) AS dundaj_une,
    SUM(bm.mor_dun) AS niit_dun
FROM borluulalt_mor bm
GROUP BY bm.ongots
ORDER BY niit_jin_kg DESC;

SELECT 
    ka.avagch_ner,
    ka.avagch_torol,
    COUNT(nb.borluulalt_id) AS borluulaltiin_too,
    SUM(nb.niit_dun) AS niit_khudaldan_avalt
FROM khudaldan_avagch ka
JOIN nooluur_borluulalt nb ON ka.avagch_id = nb.avagch_id
GROUP BY ka.avagch_ner, ka.avagch_torol
HAVING SUM(nb.niit_dun) > 50000000
ORDER BY niit_khudaldan_avalt DESC;

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    b.bag_ner,
    t.too_tolgoi AS yamaanii_too
FROM orkh o
JOIN bag b ON o.bag_id = b.bag_id
JOIN toollogo t ON o.orkh_id = t.orkh_id
WHERE t.toollogo_on = 2024 
  AND t.mal_torol_id = (SELECT mal_torol_id FROM mal_torol WHERE torol_ner = 'Ямаа')
  AND t.too_tolgoi >= 150
ORDER BY t.too_tolgoi DESC;

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    b.bag_ner
FROM orkh o
JOIN bag b ON o.bag_id = b.bag_id
WHERE NOT EXISTS (
    SELECT 1 FROM nooluur_borluulalt nb WHERE nb.orkh_id = o.orkh_id
);

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    t24.too_tolgoi AS yamaa_2024,
    (SELECT t23.too_tolgoi 
     FROM toollogo t23 
     WHERE t23.orkh_id = o.orkh_id 
       AND t23.mal_torol_id = t24.mal_torol_id 
       AND t23.toollogo_on = 2023) AS yamaa_2023
FROM orkh o
JOIN toollogo t24 ON o.orkh_id = t24.orkh_id
JOIN mal_torol m ON t24.mal_torol_id = m.mal_torol_id
WHERE m.torol_ner = 'Ямаа' 
  AND t24.toollogo_on = 2024
  AND t24.too_tolgoi > (
      SELECT t23.too_tolgoi 
      FROM toollogo t23 
      WHERE t23.orkh_id = o.orkh_id 
        AND t23.mal_torol_id = t24.mal_torol_id 
        AND t23.toollogo_on = 2023
  );

SELECT 
    avagch_ner,
    avagch_torol,
    kvot_kg,
    uldegdel_kvot_kg,
    ROUND(((kvot_kg - uldegdel_kvot_kg) / kvot_kg) * 100, 2) AS ashiglalt_huvi
FROM khudaldan_avagch
WHERE ((kvot_kg - uldegdel_kvot_kg) / kvot_kg) >= 0.05
ORDER BY ashiglalt_huvi DESC;

SELECT 
    b.bag_ner,
    COUNT(DISTINCT o.orkh_id) AS orkhiin_too,
    COALESCE(SUM(t.too_tolgoi), 0) AS niit_mal,
    ROUND(COALESCE(AVG(t.too_tolgoi), 0), 1) AS dundaj_mal_neg_torold
FROM bag b
LEFT JOIN orkh o ON b.bag_id = o.bag_id
LEFT JOIN toollogo t ON o.orkh_id = t.orkh_id AND t.toollogo_on = 2024
GROUP BY b.bag_ner
HAVING COUNT(DISTINCT o.orkh_id) > 0
ORDER BY niit_mal DESC;

WITH orkh_orlogo AS (
    SELECT 
        nb.orkh_id,
        SUM(nb.niit_dun) AS niit_orlogo,
        COUNT(nb.borluulalt_id) AS borluulalt_too
    FROM nooluur_borluulalt nb
    GROUP BY nb.orkh_id
),
orkh_mal AS (
    SELECT 
        t.orkh_id,
        SUM(t.too_tolgoi) AS niit_mal_2024
    FROM toollogo t
    WHERE t.toollogo_on = 2024
    GROUP BY t.orkh_id
)
SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    om.niit_mal_2024,
    COALESCE(oo.niit_orlogo, 0) AS niit_orlogo_2024,
    COALESCE(oo.borluulalt_too, 0) AS borluulalt_too
FROM orkh o
LEFT JOIN orkh_mal om ON o.orkh_id = om.orkh_id
LEFT JOIN orkh_orlogo oo ON o.orkh_id = oo.orkh_id
ORDER BY niit_orlogo_2024 DESC;

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    nb.niit_dun,
    DENSE_RANK() OVER (ORDER BY nb.niit_dun DESC) AS orlogo_erevbel
FROM nooluur_borluulalt nb
JOIN orkh o ON nb.orkh_id = o.orkh_id
LIMIT 10;

SELECT 
    ka.avagch_ner,
    nb.borluulalt_id,
    nb.ognoo,
    nb.niit_dun,
    SUM(nb.niit_dun) OVER (PARTITION BY ka.avagch_id ORDER BY nb.ognoo, nb.borluulalt_id) AS hurimtlagdsan_dun
FROM nooluur_borluulalt nb
JOIN khudaldan_avagch ka ON nb.avagch_id = ka.avagch_id
ORDER BY ka.avagch_ner, nb.ognoo;

SELECT orkh_id FROM toollogo WHERE toollogo_on = 2024
EXCEPT
SELECT DISTINCT orkh_id FROM nooluur_borluulalt WHERE EXTRACT(YEAR FROM ognoo) = 2024;

SELECT avagch_ner AS nersil, 'Хоршоо' AS turul, utas FROM khudaldan_avagch WHERE avagch_torol = 'Хоршоо'
UNION ALL
SELECT avagch_ner AS nersil, 'Хувь ченж' AS turul, utas FROM khudaldan_avagch WHERE avagch_torol = 'Хувь_ченж';

SELECT 
    m.registriin_dugaar AS malchin_rd,
    m.ner AS malchin_ner,
    m.turshlaga_jil,
    COALESCE(a.ner, 'Ахлагчгүй (Бие даасан)') AS akhlagch_ner
FROM malchin m
LEFT JOIN malchin a ON m.akhlagch_malchin_id = a.malchin_id
ORDER BY m.turshlaga_jil DESC;

SELECT 
    o.orkh_kod,
    o.ovoo_ner,
    b.bag_ner,
    t.too_tolgoi AS yamaanii_too
FROM orkh o
JOIN bag b ON o.bag_id = b.bag_id
JOIN toollogo t ON o.orkh_id = t.orkh_id
JOIN mal_torol m ON t.mal_torol_id = m.mal_torol_id
WHERE m.torol_ner = 'Ямаа' AND t.toollogo_on = 2024
  AND t.too_tolgoi > (
      SELECT AVG(t2.too_tolgoi)
      FROM orkh o2
      JOIN toollogo t2 ON o2.orkh_id = t2.orkh_id
      WHERE o2.bag_id = o.bag_id 
        AND t2.mal_torol_id = t.mal_torol_id 
        AND t2.toollogo_on = 2024
  );

SELECT 
    nb.borluulalt_id,
    nb.ognoo,
    nb.niit_dun,
    o.ovoo_ner
FROM nooluur_borluulalt nb
JOIN orkh o ON nb.orkh_id = o.orkh_id
WHERE EXISTS (
    SELECT 1 
    FROM borluulalt_mor bm 
    WHERE bm.borluulalt_id = nb.borluulalt_id 
      AND bm.jin_kg >= 40.00
);

SELECT 
    EXTRACT(MONTH FROM ognoo) AS sar,
    SUM(niit_dun) AS sariin_orlogo,
    LAG(SUM(niit_dun), 1) OVER (ORDER BY EXTRACT(MONTH FROM ognoo)) AS umnukh_sar,
    SUM(niit_dun) - LAG(SUM(niit_dun), 1) OVER (ORDER BY EXTRACT(MONTH FROM ognoo)) AS zuruu
FROM nooluur_borluulalt
GROUP BY EXTRACT(MONTH FROM ognoo)
ORDER BY sar;

SELECT 
    o.orkh_kod,
    m.torol_ner,
    t.too_tolgoi,
    t.tul_mal,
    ROUND((t.tul_mal::numeric / NULLIF(t.too_tolgoi, 0)) * 100, 1) AS tul_ezlekh_huvi
FROM toollogo t
JOIN orkh o ON t.orkh_id = o.orkh_id
JOIN mal_torol m ON t.mal_torol_id = m.mal_torol_id
WHERE t.toollogo_on = 2024 
  AND (t.tul_mal::numeric / NULLIF(t.too_tolgoi, 0)) >= 0.25
ORDER BY tul_ezlekh_huvi DESC;

SELECT 
    bm.borluulalt_id,
    bm.ongots,
    bm.jin_kg,
    bm.negj_une,
    CASE 
        WHEN bm.negj_une >= 140000 THEN 'Өндөр үнэтэй (Дээд зэрэглэл)'
        WHEN bm.negj_une BETWEEN 120000 AND 139999 THEN 'Дундаж үнэтэй'
        ELSE 'Хямд үнэтэй'
    END AS uneliin_zereglel
FROM borluulalt_mor bm
LIMIT 15;
