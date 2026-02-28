-- =========================================================================
-- 模块: Compliance Library (Data Refinement - Comprehensive Version)
-- 策略: 1. ID-First 映射 2. 全量翻译补全 3. 默认标准锚定
-- =========================================================================

-- 1. 增加 is_default 字段 (如果之前已执行可忽略)
ALTER TABLE base.compliance_standard 
ADD COLUMN IF NOT EXISTS is_default boolean DEFAULT false;

-- 2. 基于截图 UUID 进行全量无损翻译更新
UPDATE base.compliance_standard
SET description = CASE id
    -- 处理之前漏掉的项 (根据截图 image_65e135.png)
    WHEN 'e448dc48-9567-43b8-ab17-c4bb1a972182' THEN 'Early version of emergency lighting standard'
    WHEN '1618c48b-bd6c-45b9-b462-024342613790' THEN 'Previous version of fire hydrant standard'
    WHEN 'eede96af-4b5e-44a8-b17d-d833f89e0df3' THEN 'Previous version of backflow prevention standard'
    WHEN 'eb3981df-cb2f-4dfa-95d2-a86fb9f2000b' THEN 'European alternative standard for lifts'
    
    -- 补全其余所有项以确保一致性
    WHEN 'abd1830e-9f9b-452b-ae4c-a21ff0729049' THEN 'Previous version of sprinkler standard'
    WHEN '1475731d-a476-403a-bc08-d2d80d78d4f7' THEN 'Early version of sprinkler standard'
    WHEN '64489731-e146-4f7f-b7ca-9fa1c1f18de2' THEN 'Residential light sprinkler systems'
    WHEN '3d494cf6-b822-4bdd-8580-d86e560f081f' THEN 'Current standard for emergency lighting maintenance'
    WHEN 'c634a693-e173-4778-8cd3-8f9b83536bf1' THEN 'Current standard for fire hydrants'
    WHEN '8b827b24-329e-422c-b716-afb7a2aac28c' THEN 'Current standard for backflow prevention device testing'
    WHEN '21700884-be93-4de8-a14c-c236f7f1fcc3' THEN 'Core NZ lift maintenance standard'
    WHEN '0757dac2-4aba-4130-8669-1ad228262f89' THEN 'HVAC microbial control and maintenance standard'
    WHEN '3e705824-b7ed-4a98-87ca-612bbc12ed84' THEN 'Fall-arrest and height safety standard'
    WHEN '4cd1a151-4a35-46a0-9f7d-aa3f2134d205' THEN 'Default manual for non-standard systems (MBIE Handbook)'
    ELSE description 
END;

-- 3. 锁定 MBIE Handbook 为系统级默认保底标准
UPDATE base.compliance_standard 
SET is_default = true 
WHERE id = '4cd1a151-4a35-46a0-9f7d-aa3f2134d205';

-- 4. 添加字段注释 (符合 RLS 管理习惯)
COMMENT ON COLUMN base.compliance_standard.is_default IS 'System-level fallback flag for non-standard or unmatched compliance items';