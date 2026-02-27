const { spawn } = require("child_process");
const path = require("path");
const root = path.join(__dirname, "..");

const nextDev = spawn("npx", ["next", "dev"], {
  stdio: "inherit",
  shell: true,
  cwd: root,
});

// 开发服务器就绪后自动打开浏览器（约 4 秒）
const OPEN_DELAY_MS = 4000;
setTimeout(() => {
  require("open")("http://localhost:3000").catch(() => {});
}, OPEN_DELAY_MS);

nextDev.on("error", (err) => {
  console.error(err);
  process.exit(1);
});

nextDev.on("exit", (code) => {
  process.exit(code ?? 0);
});
