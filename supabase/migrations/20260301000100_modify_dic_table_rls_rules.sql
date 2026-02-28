-- 开启 base.frequency_dict 的行级安全
ALTER TABLE base.frequency_dict ENABLE ROW LEVEL SECURITY;

-- 创建全员只读策略
CREATE POLICY "Allow read-only access for frequency_dict" 
ON base.frequency_dict 
FOR SELECT 
TO anon, authenticated 
USING (true);

-- 确保角色拥有 SELECT 权限
GRANT SELECT ON base.frequency_dict TO anon, authenticated;