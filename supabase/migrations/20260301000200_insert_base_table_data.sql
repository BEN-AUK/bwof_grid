-- 1. 删除限制过严的单列唯一约束
-- 这将允许 standard_code 在表中重复（只要 version 不同）
ALTER TABLE base.compliance_standard 
DROP CONSTRAINT IF EXISTS base_compliance_standard_standard_code_key;

-- 2. 验证并确保联合唯一约束存在（如果不存在则添加）
-- 这样可以确保同一个标准的同一个版本不会被重复录入
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'base_compliance_standard_code_version_key'
    ) THEN
        ALTER TABLE base.compliance_standard 
        ADD CONSTRAINT base_compliance_standard_code_version_key UNIQUE (standard_code, version);
    END IF;
END $$;

-- =========================================================================
-- 模块: Compliance Library (Full Production Data Load v3)
-- 目标 Schema: base
-- 准则: 
-- 1. 清空所有旧数据 (CASCADE)
-- 2. 灌入 5 个核心频率
-- 3. 无损恢复全量标准字典 (JSON频率锁定 inspect/test)
-- 4. 无损恢复 16 个主类及全量详细子类
-- 5. 精准锚定 default_standard_id (仅在 100% 确信对应新西兰现行主力标准时赋值)
-- =========================================================================

-- 1. 安全清空所有基础字典数据
TRUNCATE 
  base.sub_category, 
  base.main_category, 
  base.compliance_standard, 
  base.frequency_dict 
CASCADE;

-- ==========================================
-- 2. 插入核心频率字典 (MVP 5 项)
-- ==========================================
INSERT INTO base.frequency_dict (id, name, display_name, interval_expression, expected_slots_per_year, is_standard)
VALUES
  ('c42c13d7-46f0-4d57-8df7-51c34a2e8c25', 'weekly', 'Weekly', 'P1W', 52, true),
  ('f9e612cb-23c8-47ad-9d9f-0c9f13dbf46b', 'monthly', 'Monthly', 'P1M', 12, true),
  ('b0df3f91-18e3-4c9b-8772-2d1b0d74ebba', 'quarterly', 'Quarterly (3-Monthly)', 'P3M', 4, true),
  ('d17b5e4c-9f62-42da-a5b8-5c0245b796d1', '6-monthly', '6-Monthly', 'P6M', 2, true),
  ('8a9b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d', 'annual', 'Annual', 'P1Y', 1, true);

-- ==========================================
-- 3. 插入全量合规标准 (包含历史版本)
-- ==========================================
INSERT INTO base.compliance_standard 
  (id, standard_code, standard_name, version, is_deprecated, default_frequency, description)
VALUES
  -- 报警系统 (SS 2)
  ('0824105a-0ba1-4491-be4d-34197f3dd9c9', 'NZS 4512', 'Fire detection and alarm systems in buildings', '2021', false, '{"inspect": "monthly", "test": "annual"}', '现行最新版'),
  ('94516878-91a8-43b5-856f-c3f5ee86d222', 'NZS 4512', 'Fire detection and alarm systems in buildings', '2010', true, '{"inspect": "monthly", "test": "annual"}', '上一代标准'),
  ('d691d944-01ee-4461-92c5-7649ea8977de', 'NZS 4512', 'Fire alarm systems in buildings', '2003', true, '{"inspect": "monthly", "test": "annual"}', '早期标准'),
  
  -- 喷淋系统 (SS 1/1)
  ('13df19a9-4072-4cb5-b233-b35e01c198e3', 'NZS 4541', 'Automatic fire sprinkler systems', '2020', false, '{"inspect": "monthly", "test": "annual"}', '现行最新版'),
  ('abd1830e-9f9b-452b-ae4c-a21ff0729049', 'NZS 4541', 'Automatic fire sprinkler systems', '2013', true, '{"inspect": "monthly", "test": "annual"}', '上一代标准'),
  ('1475731d-a476-403a-bc08-d2d80d78d4f7', 'NZS 4541', 'Automatic fire sprinkler systems', '2007', true, '{"inspect": "monthly", "test": "annual"}', '早期标准'),
  ('64489731-e146-4f7f-b7ca-9fa1c1f18de2', 'NZS 4515', 'Fire sprinkler systems for life safety in sleeping occupancies', '2009', false, '{"inspect": "monthly", "test": "annual"}', '住宅轻型喷淋'),

  -- 应急照明 (SS 4)
  ('3d494cf6-b822-4bdd-8580-d86e560f081f', 'AS/NZS 2293.2', 'Emergency escape lighting and exit signs', '2019', false, '{"inspect": "6-monthly", "test": "annual"}', '现行标准'),
  ('e448dc48-9567-43b8-ab17-c4bb1a972182', 'AS/NZS 2293.2', 'Emergency evacuation lighting', '1995', true, '{"inspect": "6-monthly", "test": "annual"}', '早期标准'),

  -- 消防栓/立管 (SS 6)
  ('c634a693-e173-4778-8cd3-8f9b83536bf1', 'NZS 4510', 'Fire hydrant systems for buildings', '2022', false, '{"inspect": "monthly", "test": "annual"}', '现行标准'),
  ('1618c48b-bd6c-45b9-b462-024342613790', 'NZS 4510', 'Fire hydrant systems for buildings', '2008', true, '{"inspect": "monthly", "test": "annual"}', '上一代标准'),

  -- 防回流阀 (SS 7)
  ('8b827b24-329e-422c-b716-afb7a2aac28c', 'AS/NZS 2845.3', 'Water supply - Backflow prevention devices', '2020', false, '{"test": "annual"}', '现行标准'),
  ('eede96af-4b5e-44a8-b17d-d833f89e0df3', 'AS/NZS 2845.3', 'Water supply - Backflow prevention devices', '2010', true, '{"test": "annual"}', '上一代标准'),

  -- 电梯 (SS 8)
  ('21700884-be93-4de8-a14c-c236f7f1fcc3', 'NZS 4332', 'Non-domestic passenger and goods lifts', '1997', false, '{"inspect": "monthly", "test": "annual"}', '新西兰核心标准'),
  ('eb3981df-cb2f-4dfa-95d2-a86fb9f2000b', 'EN 81-20', 'Safety rules for the construction and installation of lifts', '2014', false, '{"inspect": "monthly", "test": "annual"}', '欧洲替代标准'),

  -- 机械通风 (SS 9)
  ('0757dac2-4aba-4130-8669-1ad228262f89', 'AS/NZS 3666.2', 'Air-handling and water systems of buildings', '2011', false, '{"inspect": "monthly", "test": "annual"}', 'HVAC标准'),

  -- 高空作业锚点 (SS 10)
  ('3e705824-b7ed-4a98-87ca-612bbc12ed84', 'AS/NZS 1891.4', 'Industrial fall-arrest systems and devices', '2009', false, '{"inspect": "6-monthly", "test": "annual"}', '防坠落标准'),

  -- 兜底手册
  ('4cd1a151-4a35-46a0-9f7d-aa3f2134d205', 'MBIE Handbook', 'Compliance Schedule Handbook', '2014', false, '{"inspect": "monthly", "test": "annual"}', '非标系统默认手册');

-- ==========================================
-- 4. 插入全量主分类字典 (16 项完整版)
-- ==========================================
INSERT INTO base.main_category (id, code, name, sort_order, aliases)
VALUES
  ('b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1', 'Automatic systems for fire suppression', 10, ARRAY['fire suppression', 'sprinklers', 'suppression system', 'extinguishing system', 'fire pump', 'flooding system', 'deluge', 'sprinkler system']),
  ('629d14aa-d2d5-498d-8422-2f36c4cdc4f3', 'SS 2', 'Automatic or manual emergency warning systems for fire or other dangers', 20, ARRAY['fire alarm', 'smoke alarm', 'emergency warning', 'EWIS', 'OWS', 'fire panel', 'FAP', 'evacuation system', 'fire detection', 'MCP', 'manual call point']),
  ('69d4f270-153e-4cb0-83db-24a5fdbfa9a7', 'SS 3', 'Electromagnetic or automatic doors or windows', 30, ARRAY['auto door', 'automatic door', 'sliding door', 'access control', 'maglock', 'magnetic lock', 'door hold open', 'fire door', 'sensor door', 'delayed egress']),
  ('3f6ba030-3dea-4fb6-b2a7-d255c188933c', 'SS 4', 'Emergency lighting systems', 40, ARRAY['emergency light', 'exit sign', 'egress light', 'e-lite', 'e-light', 'spitfire', 'running man', 'backup lighting', 'emergency luminaire']),
  ('59075c14-6e52-4ae6-a5f7-a5bf84d802b5', 'SS 5', 'Escape route pressurisation systems', 50, ARRAY['pressurisation', 'stairwell pressurisation', 'stair pressurisation', 'escape route pressure', 'stair fan']),
  ('94785421-30a8-4184-8f4f-0f5faf81e178', 'SS 6', 'Riser mains for use by fire services', 60, ARRAY['riser main', 'fire hydrant', 'hydrant system', 'dry riser', 'wet riser', 'fire hose reel', 'building hydrant']),
  ('5e6aa429-8001-4163-953b-758dab9cc113', 'SS 7', 'Automatic backflow preventers connected to a potable water supply', 70, ARRAY['backflow', 'backflow preventer', 'BFP', 'RPZ', 'reduced pressure zone', 'double check valve', 'DCV', 'boundary backflow']),
  ('ef666eb8-8f2e-462a-8312-df9c95565586', 'SS 8', 'Lifts, escalators, travelators, or other systems for moving people or goods within buildings', 80, ARRAY['lift', 'elevator', 'escalator', 'moving walk', 'vertical transport', 'dumbwaiter', 'travelator', 'passenger lift', 'goods lift']),
  ('3f20e31e-3818-457c-8f70-0c70f3278ff3', 'SS 9', 'Mechanical ventilation or air conditioning systems', 90, ARRAY['HVAC', 'mechanical ventilation', 'air conditioning', 'air con', 'extract system', 'supply system', 'mechanical services', 'exhaust fan', 'AHU', 'FCU']),
  ('90aed579-7bfb-4af7-b315-93c96ed505b3', 'SS 10', 'Building maintenance units providing access to exterior and interior walls of buildings', 100, ARRAY['BMU', 'building maintenance unit', 'abseil', 'facade access', 'window washing system', 'height safety', 'anchor points']),
  ('af14648e-4a1f-42ee-81ef-28dc6a99ed74', 'SS 11', 'Laboratory fume cupboards', 110, ARRAY['fume cupboard', 'fume hood', 'lab extraction', 'fume scrubber']),
  ('37af3769-0528-469e-a1d5-5c19f0b65ac4', 'SS 12', 'Audio loops or other assistive listening systems', 120, ARRAY['audio loop', 'hearing loop', 'assistive listening', 'induction loop', 'deaf loop', 'FM loop']),
  ('ff609d87-b28a-4ef0-bd1f-34f1c50c3202', 'SS 13', 'Smoke control systems', 130, ARRAY['smoke control', 'smoke extract', 'smoke exhaust', 'smoke extraction', 'smoke curtain', 'natural smoke ventilation', 'smoke baffle']),
  ('bcb5efa4-8fe5-4edd-b402-cd9aa27a7f21', 'SS 14', 'Emergency power systems for, or signs relating to, a system or feature specified in any of clauses 1 to 13', 140, ARRAY['generator', 'emergency power', 'backup power', 'UPS', 'genset', 'SS signs', 'system signage', 'standby generator']),
  ('dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15', 'Any or all of the following features, so long as they form part of a building''s means of escape from fire', 150, ARRAY['means of escape', 'final exit', 'fire separation', 'smoke separation', 'evacuation sign', 'fire cell', 'fire stopping', 'fire wall']),
  ('d759095b-e375-433d-8131-44a0ba8ee828', 'SS 16', 'Cable cars', 160, ARRAY['cable car', 'funicular', 'private cable car']);

-- ==========================================
-- 5. 插入全量详细子分类字典 (绑定 100% 确信的默认标准)
-- ==========================================
INSERT INTO base.sub_category 
  (id, main_category_id, ss_code, name, default_standard_id, is_mandatory, aliases)
VALUES
  -- SS 1 细分
  ('6c0b7aac-7028-4556-b0f6-6f91ecaf7f79', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/1', 'Automatic sprinkler systems', '13df19a9-4072-4cb5-b233-b35e01c198e3', true, ARRAY['wet pipe', 'dry pipe', 'pre-action', 'fire sprinkler', 'sprinkler head', 'control valve', 'water gong', 'alarm valve', 'FDC']),
  ('8f52141e-f624-4ceb-a6bd-2008cd801d8d', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/2', 'Automatic gas flood systems', NULL, false, ARRAY['gas flood', 'FM200', 'NOVEC', 'Inergen', 'argonite', 'CO2 flood', 'IG-541', 'halon', 'clean agent']),
  ('af1d3acf-8cb9-4328-9180-cb331a724ef6', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/3', 'Automatic foam flood systems', NULL, false, ARRAY['foam flood', 'AFFF', 'high expansion foam', 'foam generator', 'foam suppression']),
  ('3f97acbb-ce4e-4925-a826-7578a1aa3c2e', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/4', 'Automatic dry powder systems', NULL, false, ARRAY['dry powder system', 'dry chemical system', 'powder flood']),
  ('80762661-a068-4452-bd75-7b44e0ea276d', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/5', 'Automatic solid aerosol systems', NULL, false, ARRAY['aerosol system', 'solid aerosol', 'stat-x']),
  ('7f0c653a-10dd-4c11-9ca0-e95f2af53706', 'b2e883fc-6abe-4275-aceb-9183ab724e71', 'SS 1/6', 'Automatic water mist systems', NULL, false, ARRAY['water mist', 'high pressure mist', 'fog system', 'fog suppression']),

  -- SS 2 独立项
  ('77d5a44b-0a80-4486-b560-6644fc2f25ca', '629d14aa-d2d5-498d-8422-2f36c4cdc4f3', 'SS 2', 'Emergency warning systems for fire or other dangers', '0824105a-0ba1-4491-be4d-34197f3dd9c9', true, ARRAY['smoke detector', 'heat detector', 'manual call point', 'MCP', 'sounder', 'flasher', 'VAD', 'aspirating', 'VESDA', 'FDCIE', 'type 2', 'type 3', 'type 4', 'type 5']),

  -- SS 3 细分
  ('c8797c96-8206-4bf6-92ac-32496e849dc9', '69d4f270-153e-4cb0-83db-24a5fdbfa9a7', 'SS 3/1', 'Automatic doors', NULL, false, ARRAY['sliding door', 'revolving door', 'swing door', 'sensor door', 'auto-slider']),
  ('806330a1-760f-4dab-85a2-f7c82f36a2a7', '69d4f270-153e-4cb0-83db-24a5fdbfa9a7', 'SS 3/2', 'Access controlled doors', NULL, false, ARRAY['swipe card', 'keypad', 'fob reader', 'maglok', 'delayed egress', 'electric strike', 'electromagnetic lock', 'push button exit', 'REX sensor']),
  ('bca94dbc-cc5b-418e-99a2-8801dab9c3bb', '69d4f270-153e-4cb0-83db-24a5fdbfa9a7', 'SS 3/3', 'Interfaced fire or smoke doors or windows', NULL, false, ARRAY['door holder', 'electromagnetic hold open', 'smoke stop door', 'fire shutter', 'door release', 'auto-closing fire door']),

  -- SS 4 独立项
  ('343ed845-f720-498d-8c4e-33534e65887e', '3f6ba030-3dea-4fb6-b2a7-d255c188933c', 'SS 4', 'Emergency lighting systems', '3d494cf6-b822-4bdd-8580-d86e560f081f', true, ARRAY['battery backup light', 'emergency luminaire', 'exit luminaire', 'monitored emergency lighting', 'spitfire', 'running man', 'e-lite']),

  -- SS 5 独立项
  ('72291123-da62-432b-be43-d059caa3210f', '59075c14-6e52-4ae6-a5f7-a5bf84d802b5', 'SS 5', 'Escape route pressurisation systems', NULL, false, ARRAY['pressurisation fan', 'stairwell pressurisation', 'stair fan', 'relief damper', 'overpressure damper']),

  -- SS 6 独立项
  ('8e10cc2c-4c29-4eb8-a5c3-5965ed07317c', '94785421-30a8-4184-8f4f-0f5faf81e178', 'SS 6', 'Riser mains for use by fire services', 'c634a693-e173-4778-8cd3-8f9b83536bf1', false, ARRAY['riser main', 'fire hydrant', 'hydrant system', 'dry riser', 'wet riser', 'hydrant inlet', 'boost connection']),

  -- SS 7 独立项
  ('c83049ec-b528-47f1-9d05-5df8e335a3ea', '5e6aa429-8001-4163-953b-758dab9cc113', 'SS 7', 'Automatic backflow preventers', '8b827b24-329e-422c-b716-afb7a2aac28c', false, ARRAY['backflow preventer', 'BFP', 'RPZ', 'reduced pressure zone', 'double check valve', 'DCV', 'air gap', 'boundary backflow']),

  -- SS 8 细分
  ('e5fbebb7-77a4-47e7-949d-2e9eb6fb249c', 'ef666eb8-8f2e-462a-8312-df9c95565586', 'SS 8/1', 'Passenger-carrying lifts', '21700884-be93-4de8-a14c-c236f7f1fcc3', false, ARRAY['passenger lift', 'commercial lift', 'traction lift', 'hydraulic lift', 'MRL', 'motor room less lift', 'elevator']),
  ('618bd0e3-782f-4e16-bad6-aae5a053e859', 'ef666eb8-8f2e-462a-8312-df9c95565586', 'SS 8/2', 'Goods lifts', '21700884-be93-4de8-a14c-c236f7f1fcc3', false, ARRAY['goods lift', 'service lift', 'dumbwaiter', 'freight elevator', 'platform lift']),
  ('ed9d070a-9b9d-4ee8-aac5-1c1e70eac3a0', 'ef666eb8-8f2e-462a-8312-df9c95565586', 'SS 8/3', 'Escalators and moving walks', NULL, false, ARRAY['escalator', 'travelator', 'moving walk', 'moving pathway']),

  -- SS 9 独立项
  ('6353c0b7-9c4c-41cd-a4c2-0a62ea54dc78', '3f20e31e-3818-457c-8f70-0c70f3278ff3', 'SS 9', 'Mechanical ventilation or air conditioning systems', '0757dac2-4aba-4130-8669-1ad228262f89', false, ARRAY['AHU', 'FCU', 'air handling unit', 'fan coil unit', 'extract fan', 'supply fan', 'chiller', 'cooling tower', 'exhaust system', 'makeup air']),

  -- SS 10 独立项
  ('5f6908bd-54d6-4eef-9325-6626dd2e392e', '90aed579-7bfb-4af7-b315-93c96ed505b3', 'SS 10', 'Building maintenance units', '3e705824-b7ed-4a98-87ca-612bbc12ed84', false, ARRAY['BMU', 'abseil point', 'facade access', 'window washing', 'height safety anchor', 'fall arrest system', 'davits']),

  -- SS 11 独立项
  ('b4e235b5-61c8-4699-99bc-fb9460020b8e', 'af14648e-4a1f-42ee-81ef-28dc6a99ed74', 'SS 11', 'Laboratory fume cupboards', NULL, false, ARRAY['fume cupboard', 'fume hood', 'lab extraction', 'fume scrubber', 'biosafety cabinet', 'local exhaust ventilation']),

  -- SS 12 细分
  ('3065417c-ec6c-48e0-8715-4e9511dc87d1', '37af3769-0528-469e-a1d5-5c19f0b65ac4', 'SS 12/1', 'Audio loops', NULL, false, ARRAY['audio loop', 'hearing loop', 'induction loop', 'deaf loop', 'T-coil loop']),
  ('25127829-a327-430d-8d1c-301ce3b84885', '37af3769-0528-469e-a1d5-5c19f0b65ac4', 'SS 12/2', 'FM radio frequency systems and infrared beam systems', NULL, false, ARRAY['FM loop', 'infrared listening', 'IR hearing system', 'assistive listening device', 'ALD']),

  -- SS 13 细分
  ('60e247ac-0f69-4549-8f93-35b86a10f1d4', 'ff609d87-b28a-4ef0-bd1f-34f1c50c3202', 'SS 13/1', 'Mechanical smoke control', NULL, false, ARRAY['smoke extract fan', 'smoke exhaust', 'mechanical smoke ventilation', 'make-up air fan', 'smoke control panel']),
  ('98e73573-018d-4f94-aa4f-eeb5281807de', 'ff609d87-b28a-4ef0-bd1f-34f1c50c3202', 'SS 13/2', 'Natural smoke control', NULL, false, ARRAY['natural smoke ventilation', 'auto opening vent', 'AOV', 'smoke louver', 'smoke vent']),
  ('3b333efd-7d7e-41dd-b14f-f33c5232df95', 'ff609d87-b28a-4ef0-bd1f-34f1c50c3202', 'SS 13/3', 'Smoke curtains', NULL, false, ARRAY['smoke curtain', 'smoke baffle', 'draft curtain', 'automatic smoke curtain']),

  -- SS 14 细分
  ('7702843d-ee23-4a37-b727-93b2bfc032b0', 'bcb5efa4-8fe5-4edd-b402-cd9aa27a7f21', 'SS 14/1', 'Emergency power systems', NULL, false, ARRAY['generator', 'UPS', 'genset', 'backup power', 'standby generator', 'diesel generator']),
  ('8c3e1ab5-38bd-4af7-9001-39dcef2f77cc', 'bcb5efa4-8fe5-4edd-b402-cd9aa27a7f21', 'SS 14/2', 'Signs relating to a system or feature specified in clauses 1 to 13', NULL, false, ARRAY['SS signs', 'system signage', 'equipment signage', 'plant room sign']),

  -- SS 15 细分 (严格留空，多依赖C/AS2或MBIE Handbook)
  ('295d3875-4cec-41f5-9211-170843a6a4be', 'dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15/1', 'Systems for communicating spoken information intended to facilitate evacuation', NULL, false, ARRAY['PA system', 'public address', 'evacuation broadcast', 'voice alarm', 'voice comms']),
  ('d8e1bfe9-ab1d-4678-8ef0-7b7a66ec6524', 'dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15/2', 'Final exits', NULL, true, ARRAY['final exit', 'exit door', 'discharge point', 'escape route exit', 'exterior exit']),
  ('c71a1532-2be2-40ad-8ee0-794f12a96165', 'dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15/3', 'Fire separations', NULL, true, ARRAY['fire wall', 'fire door', 'fire damper', 'fire collar', 'intumescent', 'fire cell', 'fire stopping', 'passive fire', 'fire partition']),
  ('b95c25e8-1123-4c56-aa12-58e11b33c1d4', 'dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15/4', 'Signs for communicating information intended to facilitate evacuation', NULL, true, ARRAY['evacuation sign', 'evac map', 'escape route map', 'fire action notice', 'directional sign']),
  ('a1b2c3d4-5e6f-7a8b-9c0d-1e2f3a4b5c6d', 'dd3dbcef-844b-435b-a2fe-c0b3cd7baf7b', 'SS 15/5', 'Smoke separations', NULL, true, ARRAY['smoke door', 'smoke wall', 'smoke separation', 'smoke stopping', 'smoke partition']),

  -- SS 16 独立项
  ('f8e7d6c5-b4a3-9210-8172-6354e5d4c3b2', 'd759095b-e375-433d-8131-44a0ba8ee828', 'SS 16', 'Cable cars', NULL, false, ARRAY['cable car', 'funicular', 'private cable car', 'incline railway']);