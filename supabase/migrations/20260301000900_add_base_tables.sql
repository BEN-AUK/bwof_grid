-- ==========================================
-- 8. 建筑具体系统检查记录表 (Building SS Inspections) - JSONB 重构版
-- 职责：挂载于 building_specified_systems 之下，定义检查频率、责任人及结构化指令
-- ==========================================
CREATE TABLE setup.building_specified_systems_inspections (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    
    -- [强关联] 物理连接父表 building_specified_systems
    building_specified_system_id uuid NOT NULL, 
    
    -- 核心维度
    frequency_id uuid NOT NULL,          -- [外键] 关联 base.frequencies 字典表
    inspector_role text NOT NULL,        -- [硬编码枚举] 暂时采用 CHECK 约束
    
    -- 结构化指令 (JSONB)
    -- 用于存储 Checklist 步骤，例如：{"steps": ["检查压力表", "确认阀门开启"], "tools": ["压力计"]}
    inspection_instructions jsonb DEFAULT '[]'::jsonb, 
    
    -- 严格审计基线 (由 NestJS 显式注入)
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT building_ss_inspections_pkey PRIMARY KEY (id),
    
    -- 物理连接约束
    CONSTRAINT building_ss_inspections_parent_fkey FOREIGN KEY (building_specified_system_id) REFERENCES setup.building_specified_systems(id) ON DELETE CASCADE,
    
    -- 角色枚举约束
    CONSTRAINT check_inspector_role CHECK (inspector_role = ANY (ARRAY['Owner', 'IQP', 'Council', 'Tenant', 'PM']))
);

-- 防止重复生成相同规则的联合唯一索引
CREATE UNIQUE INDEX idx_unique_inspection_rule ON setup.building_specified_systems_inspections (building_specified_system_id, frequency_id, inspector_role);

-- 查询加速索引
CREATE INDEX idx_inspections_parent_lookup ON setup.building_specified_systems_inspections(building_specified_system_id);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_ss_inspections 
    BEFORE UPDATE ON setup.building_specified_systems_inspections 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- ==========================================
-- 强制安全预设 (Mandatory RLS)
-- ==========================================
ALTER TABLE setup.building_specified_systems_inspections ENABLE ROW LEVEL SECURITY;

-- 跨表鉴权策略：inspections -> systems -> buildings -> profiles.org_id
CREATE POLICY "Users can manage inspections in their organization" ON setup.building_specified_systems_inspections
    FOR ALL USING (
        building_specified_system_id IN (
            SELECT id FROM setup.building_specified_systems
            WHERE building_id IN (
                SELECT id FROM setup.buildings
                WHERE organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
            )
        )
    );

    -- 1. 增加黑话数组字段 (采用 text 数组以支持多别名映射)
ALTER TABLE base.compliance_standard 
ADD COLUMN IF NOT EXISTS ailases text[] DEFAULT '{}';

-- 2. 建立 GIN 倒排索引，将数组查询性能提升至 O(1) 级别
CREATE INDEX IF NOT EXISTS idx_compliance_standard_ai_keywords 
ON base.compliance_standard USING GIN (ailases);

-- AS/NZS 3666.2 (空调/水系统)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS3666.2', 'AS/NZS 3666.2', 'AS/NZS 3666.2:2011', 'AS/NZS 3666.2 : 2011', 'Air-handling', 'HVAC', 'Mechanical ventilation', 'Cooling towers', '3666.2', 'Air-handling 2011', 'HVAC 2011', 'Mechanical ventilation 2011', 'Cooling towers 2011', '3666.2 2011']::text[] WHERE id = '0757dac2-4aba-4130-8669-1ad228262f89';

-- NZS 4512:2021 (火警系统 最新版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4512', 'NZS 4512', 'NZS 4512:2021', 'NZS 4512 : 2021', 'Fire detection', 'Fire alarm', 'Smoke alarm', 'Manual call points', 'Type 2', 'Type 3', 'Type 4', 'Fire detection 2021', 'Fire alarm 2021', 'Smoke alarm 2021', 'Manual call points 2021', 'Type 2 2021', 'Type 3 2021', 'Type 4 2021']::text[] WHERE id = '0824105a-0ba1-4491-be4d-34197f3dd9c9';

-- NZS 4512:2010 (火警系统 老版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4512', 'NZS 4512', 'NZS 4512:2010', 'NZS 4512 : 2010', 'Fire detection', 'Fire alarm', 'Smoke alarm', 'Manual call points', 'Type 2', 'Type 3', 'Type 4', 'Fire detection 2010', 'Fire alarm 2010', 'Smoke alarm 2010', 'Manual call points 2010', 'Type 2 2010', 'Type 3 2010', 'Type 4 2010']::text[] WHERE id = '94516878-91a8-43b5-856f-c3f5ee86d222';

-- NZS 4512:2003 (火警系统 远古版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4512', 'NZS 4512', 'NZS 4512:2003', 'NZS 4512 : 2003', 'Fire detection', 'Fire alarm', 'Smoke alarm', 'Manual call points', 'Type 2', 'Type 3', 'Type 4', 'Fire detection 2003', 'Fire alarm 2003', 'Smoke alarm 2003', 'Manual call points 2003', 'Type 2 2003', 'Type 3 2003', 'Type 4 2003']::text[] WHERE id = 'd691d944-01ee-4461-92c5-7649ea8977de';

-- NZS 4541:2020 (喷淋系统 最新版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4541', 'NZS 4541', 'NZS 4541:2020', 'NZS 4541 : 2020', 'Sprinkler system', 'Automatic fire sprinkler', 'Type 6', 'Type 7', 'Sprinkler system 2020', 'Automatic fire sprinkler 2020', 'Type 6 2020', 'Type 7 2020']::text[] WHERE id = '13df19a9-4072-4cb5-b233-b35e01c198e3';

-- NZS 4541:2013 (喷淋系统 13版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4541', 'NZS 4541', 'NZS 4541:2013', 'NZS 4541 : 2013', 'Sprinkler system', 'Automatic fire sprinkler', 'Type 6', 'Type 7', 'Sprinkler system 2013', 'Automatic fire sprinkler 2013', 'Type 6 2013', 'Type 7 2013']::text[] WHERE id = 'abd1830e-9f9b-452b-ae4c-a21ff0729049';

-- NZS 4541:2007 (喷淋系统 07版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4541', 'NZS 4541', 'NZS 4541:2007', 'NZS 4541 : 2007', 'Sprinkler system', 'Automatic fire sprinkler', 'Type 6', 'Type 7', 'Sprinkler system 2007', 'Automatic fire sprinkler 2007', 'Type 6 2007', 'Type 7 2007']::text[] WHERE id = '1475731d-a476-403a-bc08-d2d80d78d4f7';

-- NZS 4510:2022 (消防栓 最新版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4510', 'NZS 4510', 'NZS 4510:2022', 'NZS 4510 : 2022', 'Fire hydrant', 'Building hydrant', 'Hydrant system', 'Fire hydrant 2022', 'Building hydrant 2022', 'Hydrant system 2022']::text[] WHERE id = 'c634a693-e173-4778-8cd3-8f9b83536bf1';

-- NZS 4510:2008 (消防栓 老版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4510', 'NZS 4510', 'NZS 4510:2008', 'NZS 4510 : 2008', 'Fire hydrant', 'Building hydrant', 'Hydrant system', 'Fire hydrant 2008', 'Building hydrant 2008', 'Hydrant system 2008']::text[] WHERE id = '1618c48b-bd6c-45b9-b462-024342613790';

-- NZS 4332:1997 (电梯)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4332', 'NZS 4332', 'NZS 4332:1997', 'NZS 4332 : 1997', 'Passenger lift', 'Goods lift', 'Elevator', 'Passenger lift 1997', 'Goods lift 1997', 'Elevator 1997']::text[] WHERE id = '21700884-be93-4de8-a14c-c236f7f1fcc3';

-- EN 81-20:2014 (欧洲电梯标准)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['EN81-20', 'EN 81-20', 'EN 81-20:2014', 'EN 81-20 : 2014', 'European lift standard', 'Elevator safety rules', 'EN81', 'European lift standard 2014', 'Elevator safety rules 2014', 'EN81 2014']::text[] WHERE id = 'eb3981df-cb2f-4dfa-95d2-a86fb9f2000b';

-- AS/NZS 2293.2:2019 (应急照明 最新版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS2293.2', 'AS/NZS 2293.2', 'AS/NZS 2293.2:2019', 'AS/NZS 2293.2 : 2019', 'Emergency lighting', 'Exit signs', 'Evacuation lighting', 'E-light', 'Emergency lighting 2019', 'Exit signs 2019', 'Evacuation lighting 2019', 'E-light 2019']::text[] WHERE id = '3d494cf6-b822-4bdd-8580-d86e560f081f';

-- AS/NZS 2293.2:1995 (应急照明 老版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS2293.2', 'AS/NZS 2293.2', 'AS/NZS 2293.2:1995', 'AS/NZS 2293.2 : 1995', 'Emergency lighting', 'Exit signs', 'Evacuation lighting', 'E-light', 'Emergency lighting 1995', 'Exit signs 1995', 'Evacuation lighting 1995', 'E-light 1995']::text[] WHERE id = 'e448dc48-9567-43b8-ab17-c4bb1a972182';

-- AS/NZS 1891.4:2009 (防坠落/高空作业)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS1891.4', 'AS/NZS 1891.4', 'AS/NZS 1891.4:2009', 'AS/NZS 1891.4 : 2009', 'Fall arrest', 'Height safety', 'Anchor points', 'Safety harness', 'Roof anchors', 'Fall arrest 2009', 'Height safety 2009', 'Anchor points 2009', 'Safety harness 2009', 'Roof anchors 2009']::text[] WHERE id = '3e705824-b7ed-4a98-87ca-612bbc12ed84';

-- MBIE Handbook 2014
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['MBIEHandbook', 'MBIE Handbook', 'MBIE Handbook:2014', 'MBIE Handbook : 2014', 'Compliance Schedule Handbook', 'Section 164', 'Handbook', 'Compliance Schedule Handbook 2014', 'Section 164 2014', 'Handbook 2014']::text[] WHERE id = '4cd1a151-4a35-46a0-9f7d-aa3f2134d205';

-- NZS 4515:2009 (住宅/居住用喷淋)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['NZS4515', 'NZS 4515', 'NZS 4515:2009', 'NZS 4515 : 2009', 'Residential sprinkler', 'Sleeping occupancy sprinkler', 'Life safety sprinkler', 'Residential sprinkler 2009', 'Sleeping occupancy sprinkler 2009', 'Life safety sprinkler 2009']::text[] WHERE id = '64489731-e146-4f7f-b7ca-9fa1c1f18de2';

-- AS/NZS 2845.3:2020 (防倒流装置 最新版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS2845.3', 'AS/NZS 2845.3', 'AS/NZS 2845.3:2020', 'AS/NZS 2845.3 : 2020', 'Backflow prevention', 'BFP', 'RPZ', 'Double check valve', 'Cross connection', 'Backflow prevention 2020', 'BFP 2020', 'RPZ 2020', 'Double check valve 2020', 'Cross connection 2020']::text[] WHERE id = '8b827b24-329e-422c-b716-afb7a2aac28c';

-- AS/NZS 2845.3:2010 (防倒流装置 老版)
UPDATE base.compliance_standard SET ai_recognition_keywords = ARRAY['AS/NZS2845.3', 'AS/NZS 2845.3', 'AS/NZS 2845.3:2010', 'AS/NZS 2845.3 : 2010', 'Backflow prevention', 'BFP', 'RPZ', 'Double check valve', 'Cross connection', 'Backflow prevention 2010', 'BFP 2010', 'RPZ 2010', 'Double check valve 2010', 'Cross connection 2010']::text[] WHERE id = 'eede96af-4b5e-44a8-b17d-d833f89e0df3';