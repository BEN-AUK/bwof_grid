const fs = require('fs');
const path = require('path');

// --- 配置区 ---
const ANON_KEY = 'sb_publishable_ziIgnj1ZOXnyr9IP7AJyFA_pv2wEq98'; 
const FUNCTION_URL = 'https://exbymqyakzxibltikwum.functions.supabase.co/parse-documents';
// 请确保此路径在你的机器上是真实的
const FILE_PATH = path.resolve('D:/bwof_grid/supabase/functions/resource/warrant-of-fitness-form-12.pdf');

async function testParseFunction() {
    console.log("🔍 步骤 1: 检查文件是否存在...");
    if (!fs.existsSync(FILE_PATH)) {
        console.error(`❌ 文件不存在: ${FILE_PATH}`);
        return;
    }
    console.log(`✅ 文件确认成功: ${FILE_PATH}`);

    console.log("\n📦 步骤 2: 准备 FormData...");
    const formData = new FormData();
    
    try {
        // 读取文件并转为 Blob (Node 18+ 推荐做法)
        const fileBuffer = fs.readFileSync(FILE_PATH);
        const fileBlob = new Blob([fileBuffer], { type: 'application/pdf' });
        formData.append('files', fileBlob, 'warrant-of-fitness-form-12.pdf');
        console.log("✅ FormData 构建完成");
    } catch (err) {
        console.error("❌ 读取文件或构建 FormData 失败:", err.message);
        return;
    }

    console.log("\n🚀 步骤 3: 发送请求到 Supabase Edge Function...");
    console.log(`URL: ${FUNCTION_URL}`);

    try {
        const response = await fetch(FUNCTION_URL, {
            method: 'POST',
            headers: {
                'apikey': ANON_KEY,
                'Authorization': `Bearer ${ANON_KEY}`
            },
            body: formData,
            // 增加超时控制
            signal: AbortSignal.timeout(30000) 
        });

        console.log(`📡 收到响应 - 状态码: ${response.status} ${response.statusText}`);

        if (response.ok) {
            const data = await response.json();
            console.log("\n🎉 解析成功！返回数据如下:");
            console.log(JSON.stringify(data, null, 2));
        } else {
            const errorText = await response.text();
            console.error("\n❌ 服务器返回业务错误:");
            console.error(errorText);
        }
    } catch (err) {
        console.error("\n❌ 网络层请求失败 (fetch failed):");
        console.error(`错误消息: ${err.message}`);
        
        // 关键诊断信息：如果是证书或 DNS 问题，会在 cause 中体现
        if (err.cause) {
            console.error("底层原因 (Detailed Cause):", err.cause);
        }
        
        console.log("\n💡 建议排查:");
        console.log("1. 检查本地网络是否能访问 supabase.co (尝试 ping)");
        console.log("2. 如果是在公司内网，请检查是否需要配置代理");
        console.log("3. 尝试在终端运行命令: node -v (建议版本 18.x 或 20.x)");
    }
}

testParseFunction();