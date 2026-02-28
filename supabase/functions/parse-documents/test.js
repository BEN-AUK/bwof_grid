const fs = require('fs');
const path = require('path');

async function testUpload() {
  const PROJECT_ID = 'exbymqyakzxibltikwum';
  const ANON_KEY = 'sb_publishable_ziIgnj1ZOXnyr9IP7AJyFA_pv2wEq98'; // 👈 确保这里换成了你后台的 anon key
  
  // 使用绝对路径定位文件（resource 在 functions 目录下，与 parse-documents 平级）
  const filePath = path.join(__dirname, '..', 'resource', 'warrant-of-fitness-form-12.pdf');
  
  console.log('🔍 正在检查文件是否存在:', filePath);
  if (!fs.existsSync(filePath)) {
    console.error('❌ 错误：找不到文件！请确认 supabase/functions/resource/ 下存在该 PDF。');
    return;
  }

  console.log('📦 正在读取文件并准备 FormData...');
  const fileBuffer = fs.readFileSync(filePath);
  const blob = new Blob([fileBuffer], { type: 'application/pdf' });
  const formData = new FormData();
  formData.append('files', blob, 'test.pdf');

  const url = `https://${PROJECT_ID}.functions.supabase.co/parse-documents`;
  console.log('🚀 正在发送请求到:', url);

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 30000); // 30秒超时

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${ANON_KEY}`,
        'apikey': ANON_KEY
      },
      body: formData,
      signal: controller.signal
    });

    clearTimeout(timeout);
    console.log('✅ 收到服务器响应，状态码:', response.status);

    const result = await response.json();
    console.log('📄 解析后的数据:', JSON.stringify(result, null, 2));
  } catch (error) {
    if (error.name === 'AbortError') {
      console.error('❌ 请求超时：服务器响应太慢了。');
    } else {
      console.error('❌ 发生异常:', error.message);
    }
  }
}

testUpload();