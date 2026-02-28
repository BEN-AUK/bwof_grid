-- 更新标准表数据

-- =========================================================================
-- 模块: Compliance Library (Data Refinement - Tech Lead Version)
-- 策略: 1. 基于主键 UUID 映射 2. 字段原子化更新
-- =========================================================================

-- 1. 增加 is_default 字段 (符合你的要求)
ALTER TABLE base.compliance_standard 
ADD COLUMN IF NOT EXISTS is_default boolean DEFAULT false;

-- 2. 使用 UUID 进行精确的英文描述更新 (确保 100% 成功率与幂等性)
UPDATE base.compliance_standard
SET description = CASE id
    WHEN '0824105a-0ba1-4491-be4d-34197f3dd9c9' THEN 'Current standard for fire detection and alarm systems'
    WHEN '13df19a9-4072-4cb5-b233-b35e01c198e3' THEN 'Current standard for commercial sprinkler systems'
    WHEN '3d494cf6-b822-4bdd-8580-d86e560f081f' THEN 'Current standard for emergency lighting maintenance'
    WHEN '8b827b24-329e-422c-b716-afb7a2aac28c' THEN 'Current standard for backflow prevention device testing'
    WHEN '94516878-91a8-43b5-856f-c3f5ee86d222' THEN 'Previous version of fire alarm standard'
    WHEN 'd691d944-01ee-4461-92c5-7649ea8977de' THEN 'Early version of fire alarm standard'
    WHEN 'abd1830e-9f9b-452b-ae4c-a21ff0729049' THEN 'Previous version of sprinkler standard'
    WHEN '1475731d-a476-403a-bc08-d2d80d78d4f7' THEN 'Early version of sprinkler standard'
    WHEN '64489731-e146-4f7f-b7ca-9fa1c1f18de2' THEN 'Residential light sprinkler systems'
    WHEN 'c634a693-e173-4778-8cd3-8f9b83536bf1' THEN 'Current standard for fire hydrants'
    WHEN '21700884-be93-4de8-a14c-c236f7f1fcc3' THEN 'Core NZ lift maintenance standard'
    WHEN '0757dac2-4aba-4130-8669-1ad228262f89' THEN 'HVAC microbial control and maintenance standard'
    WHEN '3e705824-b7ed-4a98-87ca-612bbc12ed84' THEN 'Fall-arrest and height safety standard'
    WHEN '4cd1a151-4a35-46a0-9f7d-aa3f2134d205' THEN 'Default manual for non-standard systems (MBIE Handbook)'
    ELSE description 
END;

-- 3. 精确设置默认非标保底项
UPDATE base.compliance_standard 
SET is_default = true 
WHERE id = '4cd1a151-4a35-46a0-9f7d-aa3f2134d205';