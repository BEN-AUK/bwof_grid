-- =========================================================================
-- 模块: Compliance Library
-- 目标表: base_frequency_dict (频率计算法则字典)
-- 作用: 提供标准的日期计算引擎参数，彻底消除代码层面的硬编码
-- =========================================================================

CREATE TABLE public.base_frequency_dict (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name varchar NOT NULL UNIQUE,          -- 自然键: 'monthly', 'annual', '10-daily'
  display_name text NOT NULL,            -- UI显示: 'Monthly', 'Every 10 Days'
  interval_expression varchar NOT NULL,  -- ISO 8601 持续时间 (如 P1M, P1Y, P10D)
  expected_slots_per_year int2 NOT NULL, -- 预期年度槽位数 (如 12, 1, 36)
  is_standard boolean DEFAULT true,      -- true=系统原生, false=AI/用户在非标情况下的自定义衍生
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT base_frequency_dict_pkey PRIMARY KEY (id)
);

-- =========================================================================
-- 模块: Compliance Library
-- 目标表: base_frequency_dict
-- 策略: 极简主义 (MVP)。只提供真实业务中最核心的 5 个频率。
-- 依赖: 冷门频率交由 AI 动态推导并作为非标数据 (is_standard=false) 插入
-- =========================================================================

INSERT INTO public.base_frequency_dict 
  (id, name, display_name, interval_expression, expected_slots_per_year, is_standard)
VALUES
  -- 柴油消防泵等高频运转设备的法定最低测试频率
  ('c42c13d7-46f0-4d57-8df7-51c34a2e8c25', 'weekly', 'Weekly', 'P1W', 52, true),
  
  -- 绝大多数消防/机械系统的常规巡检频率（占比最重）
  ('f9e612cb-23c8-47ad-9d9f-0c9f13dbf46b', 'monthly', 'Monthly', 'P1M', 12, true),
  
  -- 部分水处理或老旧系统会使用季度检
  ('b0df3f91-18e3-4c9b-8772-2d1b0d74ebba', 'quarterly', 'Quarterly (3-Monthly)', 'P3M', 4, true),
  
  -- 应急照明、防坠落装置等特种设备的法定深度测试频率
  ('d17b5e4c-9f62-42da-a5b8-5c0245b796d1', '6-monthly', '6-Monthly', 'P6M', 2, true),
  
  -- BWOF 终极闭环频率，所有系统每年必须有一次大考
  ('8a9b2c3d-4e5f-6a7b-8c9d-0e1f2a3b4c5d', 'annual', 'Annual', 'P1Y', 1, true)

ON CONFLICT (name) 
DO UPDATE SET 
  display_name = EXCLUDED.display_name,
  interval_expression = EXCLUDED.interval_expression,
  expected_slots_per_year = EXCLUDED.expected_slots_per_year,
  is_standard = EXCLUDED.is_standard;