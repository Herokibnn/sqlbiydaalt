

-- 1. СУМ / ДҮҮРЭГ
CREATE TABLE sum_duureg (
    sum_id SERIAL PRIMARY KEY,
    sum_ner VARCHAR(100) NOT NULL,
    aimag_ner VARCHAR(100) NOT NULL DEFAULT 'Архангай',
    CONSTRAINT uq_sum_aimag UNIQUE (sum_ner, aimag_ner)
);

-- 2. БАГ
CREATE TABLE bag (
    bag_id SERIAL PRIMARY KEY,
    bag_ner VARCHAR(100) NOT NULL,
    sum_id INT NOT NULL REFERENCES sum_duureg(sum_id) ON DELETE CASCADE,
    CONSTRAINT uq_bag_sum UNIQUE (bag_ner, sum_id)
);

-- 3. ӨРХ
CREATE TABLE orkh (
    orkh_id SERIAL PRIMARY KEY,
    orkh_kod VARCHAR(20) UNIQUE NOT NULL,
    bag_id INT NOT NULL REFERENCES bag(bag_id) ON DELETE RESTRICT,
    ovoo_ner VARCHAR(100) NOT NULL,
    utas VARCHAR(20),
    burtgesen_ognoo DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 4. МАЛЧИН 
CREATE TABLE malchin (
    malchin_id SERIAL PRIMARY KEY,
    orkh_id INT NOT NULL REFERENCES orkh(orkh_id) ON DELETE CASCADE,
    registriin_dugaar VARCHAR(10) UNIQUE NOT NULL,
    ovog VARCHAR(50) NOT NULL,
    ner VARCHAR(50) NOT NULL,
    huis CHAR(2) NOT NULL CHECK (huis IN ('Эр', 'Эм')),
    akhlagch_malchin_id INT REFERENCES malchin(malchin_id) ON DELETE SET NULL,
    turshlaga_jil INT NOT NULL DEFAULT 0 CHECK (turshlaga_jil >= 0)
);

-- 5. МАЛЫН ТӨРӨЛ
CREATE TABLE mal_torol (
    mal_torol_id SERIAL PRIMARY KEY,
    torol_ner VARCHAR(50) UNIQUE NOT NULL
);

-- 6. ТОOЛЛОГО
-- Онцгой дүрэм 1: Тооллого жил бүр 1 удаа: нэг өрх нэг жилд нэг төрлийн малаа нэг л удаа тоолуулна.
CREATE TABLE toollogo (
    toollogo_id SERIAL PRIMARY KEY,
    orkh_id INT NOT NULL REFERENCES orkh(orkh_id) ON DELETE CASCADE,
    mal_torol_id INT NOT NULL REFERENCES mal_torol(mal_torol_id) ON DELETE RESTRICT,
    toollogo_on INT NOT NULL CHECK (toollogo_on BETWEEN 2000 AND 2100),
    too_tolgoi INT NOT NULL CHECK (too_tolgoi >= 0),
    er_mal INT NOT NULL DEFAULT 0 CHECK (er_mal >= 0),
    em_mal INT NOT NULL DEFAULT 0 CHECK (em_mal >= 0),
    tul_mal INT NOT NULL DEFAULT 0 CHECK (tul_mal >= 0),
    toolson_ognoo DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT chk_mal_niilber CHECK (too_tolgoi = er_mal + em_mal + tul_mal),
    CONSTRAINT uq_orkh_on_mal UNIQUE (orkh_id, toollogo_on, mal_torol_id)
);

-- 7. ХУДАЛДАН АВАГЧ (ISA: Хоршоо, Хувь ченж)
CREATE TABLE khudaldan_avagch (
    avagch_id SERIAL PRIMARY KEY,
    avagch_ner VARCHAR(100) NOT NULL,
    avagch_torol VARCHAR(20) NOT NULL CHECK (avagch_torol IN ('Хоршоо', 'Хувь_ченж')),
    kvot_kg NUMERIC(10, 2) NOT NULL CHECK (kvot_kg >= 0),
    uldegdel_kvot_kg NUMERIC(10, 2) NOT NULL CHECK (uldegdel_kvot_kg >= 0),
    utas VARCHAR(20),
    CONSTRAINT chk_kvot_uldegdel CHECK (uldegdel_kvot_kg <= kvot_kg)
);

-- 8. НООЛУУРЫН ҮНЭ
-- Онцгой дүрэм 2: Үнэ өнгө ба огнооноос хамаарна
CREATE TABLE nooluur_une (
    une_id SERIAL PRIMARY KEY,
    ongots VARCHAR(20) NOT NULL CHECK (ongots IN ('Цагаан', 'Бор', 'Саарал', 'Хөх')),
    ekhlekh_ognoo DATE NOT NULL,
    duusakh_ognoo DATE NOT NULL,
    negj_une NUMERIC(10, 2) NOT NULL CHECK (negj_une > 0),
    CONSTRAINT chk_ognoo CHECK (duusakh_ognoo >= ekhlekh_ognoo),
    CONSTRAINT uq_ongots_ognoo UNIQUE (ongots, ekhlekh_ognoo, duusakh_ognoo)
);

-- 9. НООЛУУРЫН БОРЛУУЛАЛТ
CREATE TABLE nooluur_borluulalt (
    borluulalt_id SERIAL PRIMARY KEY,
    orkh_id INT NOT NULL REFERENCES orkh(orkh_id) ON DELETE RESTRICT,
    avagch_id INT NOT NULL REFERENCES khudaldan_avagch(avagch_id) ON DELETE RESTRICT,
    ognoo DATE NOT NULL DEFAULT CURRENT_DATE,
    niit_dun NUMERIC(14, 2) NOT NULL DEFAULT 0 CHECK (niit_dun >= 0)
);

-- 10. БОРЛУУЛАЛТЫН МӨР (Weak Entity: nooluur_borluulalt-аас хамааралтай)
CREATE TABLE borluulalt_mor (
    borluulalt_id INT NOT NULL REFERENCES nooluur_borluulalt(borluulalt_id) ON DELETE CASCADE,
    mor_dugaar INT NOT NULL CHECK (mor_dugaar > 0),
    ongots VARCHAR(20) NOT NULL CHECK (ongots IN ('Цагаан', 'Бор', 'Саарал', 'Хөх')),
    jin_kg NUMERIC(10, 2) NOT NULL CHECK (jin_kg > 0),
    negj_une NUMERIC(10, 2) NOT NULL CHECK (negj_une > 0),
    mor_dun NUMERIC(14, 2) GENERATED ALWAYS AS (jin_kg * negj_une) STORED,
    PRIMARY KEY (borluulalt_id, mor_dugaar)
);
