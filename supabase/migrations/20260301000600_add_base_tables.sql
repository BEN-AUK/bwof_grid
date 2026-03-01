-- 1. 创建设置 Schema (如果尚未创建)
CREATE SCHEMA IF NOT EXISTS setup;

-- 2. 时间戳自动更新函数 (仅负责时间)
CREATE OR REPLACE FUNCTION setup.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 组织表 (Organizations)
CREATE TABLE setup.organizations (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    name text NOT NULL,
    
    -- 审计字段：由应用层显式传入，不再依赖 auth.uid() 触发器
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,      -- 强制应用层注入
    last_modified_by_id uuid NOT NULL, -- 强制应用层注入

    CONSTRAINT organizations_pkey PRIMARY KEY (id)
);

-- 4. 用户属性表 (Profiles)
CREATE TABLE setup.profiles (
    id uuid NOT NULL, -- 锚定 auth.users.id
    organization_id uuid NOT NULL,
    first_name text NOT NULL, -- 必填
    last_name text,           -- 可选
    role text DEFAULT 'Staff'::text CHECK (role = ANY (ARRAY['Admin'::text, 'Owner'::text, 'Staff'::text])),
    
    -- 审计字段
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT profiles_pkey PRIMARY KEY (id),
    CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT profiles_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE
);

-- 5. 仅绑定时间戳触发器
CREATE TRIGGER handle_updated_at_orgs BEFORE UPDATE ON setup.organizations FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();
CREATE TRIGGER handle_updated_at_profiles BEFORE UPDATE ON setup.profiles FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- 6. RLS 开启
ALTER TABLE setup.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE setup.profiles ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- 1. 组织表 (Organizations) 的 RLS
-- 策略：用户只能看到自己所属的那个组织记录
-- ==========================================
CREATE POLICY "Users can only view their own organization" ON setup.organizations
    FOR SELECT
    USING (
        id = (SELECT organization_id FROM setup.profiles WHERE profiles.id = auth.uid())
    );

-- ==========================================
-- 2. 用户属性表 (Profiles) 的 RLS
-- 策略 A：只能查看同公司的员工资料 (SELECT)
-- 策略 B：只能修改自己的资料 (UPDATE)
-- ==========================================

-- 允许查看同公司的所有员工
CREATE POLICY "Users can view members in the same organization" ON setup.profiles
    FOR SELECT
    USING (
        organization_id = (SELECT organization_id FROM setup.profiles WHERE profiles.id = auth.uid())
    );

-- 仅允许本人修改自己的姓名、角色等信息
CREATE POLICY "Users can update own profile" ON setup.profiles
    FOR UPDATE
    USING (
        id = auth.uid()
    )
    WITH CHECK (
        id = auth.uid()
    );

-- ==========================================
-- 5. 业主详细信息表 (Owners)
-- ==========================================
CREATE TABLE setup.owners (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL, -- 租户隔离锚点
    
    -- 基础信息 (参照 PDF 截图字段)
    name text NOT NULL,            -- Name of Owner (必填)
    contact_person text,           -- 联系人
    email text,                    -- Mailing Address 里的 Email
    phone text,                    -- Phone/Mobile
    mailing_address text,          -- Mailing Address 文本
    
    -- 审计字段 (应用层注入)
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT owners_pkey PRIMARY KEY (id),
    CONSTRAINT owners_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE
);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_owners 
    BEFORE UPDATE ON setup.owners 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- 开启 RLS 并设置组织隔离
ALTER TABLE setup.owners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage owners in their organization" ON setup.owners
    FOR ALL
    USING (
        organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
    );

    -- ==========================================
-- 6. 建筑/物业表 (Buildings) - V2 重构版
-- 职责：存储符合 NZ Building Act 要求的核心合规属性
-- ==========================================
CREATE TABLE setup.buildings (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    organization_id uuid NOT NULL, -- 租户隔离锚点
    owner_id uuid,                 -- 关联业主表
    
    -- 基础标识
    name text NOT NULL,            -- Building Name
    address text NOT NULL,         -- Full Address (原生字符串)
    council_name text,             -- 所属议会 (如：Auckland Council)

    -- 法律与土地属性 (Legal & Land)
    legal_description text,        -- Legal description of land (如 Lot/DP 号)
    year_of_first_construction text, -- 首次建造年份

    -- 建筑生命与安全分类 (Compliance & Safety)
    intended_life text,            -- Intended life of the building (如 Indefinite 或 Specified years)
    highest_fire_hazard_category text, -- Highest fire hazard category
    risk_groups text,              -- Risk group(s) (如 WB, SM, etc.)
    compliance_schedule_location text, -- Compliance schedule is kept at (实物存放点)
    
    -- 审计字段 (由应用层 NestJS 显式注入)
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by_id uuid NOT NULL,
    last_modified_by_id uuid NOT NULL,

    CONSTRAINT buildings_pkey PRIMARY KEY (id),
    CONSTRAINT buildings_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES setup.organizations(id) ON DELETE CASCADE,
    CONSTRAINT buildings_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES setup.owners(id) ON DELETE SET NULL
);

-- 绑定时间戳触发器
CREATE TRIGGER handle_updated_at_buildings 
    BEFORE UPDATE ON setup.buildings 
    FOR EACH ROW EXECUTE PROCEDURE setup.set_updated_at();

-- 开启 RLS 并设置组织隔离
ALTER TABLE setup.buildings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage buildings in their organization" ON setup.buildings
    FOR ALL
    USING (
        organization_id = (SELECT organization_id FROM setup.profiles WHERE id = auth.uid())
    );