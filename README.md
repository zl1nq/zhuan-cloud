# 筑安云 ZhuAnCloud

> 工地安全隐患"上报 → 处置 → 闭环 → 复盘"AI协同平台
> **把案头交给AI，把安全留给现场。**

第一届"海之子杯"AI智能体大赛参赛作品。安全员通过**文字 / 语音 / 图片**上报隐患，
AI自动完成**信息抽取 → 知识库检索（规范条款）→ 风险定级 → 处置建议 → 责任人匹配 → 生成整改工单（人工审核）→ 派发 → 整改跟进（附整改照片）→ 超期预警 → 按风险等级汇总周报**。

支持**邮箱验证码注册登录**（注册可选角色：安全员/安全总监/项目经理/分包责任人），四角色四套工作界面；内置模拟引擎与真实大模型**双引擎一键切换**。

**📚 文档目录**（点开即看）：
- [项目技术说明文档](docs/说明文档_筑安云.md) —— 背景痛点、功能全景、Agent架构、创新点（答辩主文档，Word版在 `docs/筑安云_项目技术说明文档.docx`）
- [演示视频拍摄脚本](docs/演示视频拍摄脚本.md) —— 2分钟分镜+讲解词（Word版：`docs/筑安云_演示视频拍摄脚本.docx`）
- 本 README —— 怎么跑起来、技术栈、演示账号

## 30秒看懂它长什么样

```
安全员(手机/电脑)                          分包责任人                    管理层
   │ 上报隐患(文字/语音/拍照)                  │                            │
   ▼                                        │                            │
┌─────────────── AI处理流水线(LangGraph) ───────────────┐                │
│ 信息抽取 → 规范检索 → 风险定级 → 处置建议 → 责任人匹配     │                │
└──────────────────────┬──────────────────────────┘                │
                工单草稿(待审核) ──安全员确认──▶ 已派发 ──▶ 整改(照片) ──▶ 复查闭环
                                                          │
                              超期自动预警 ◀────────────────┘
                              AI按风险等级汇总周报(可导出Word) ──▶ 项目经理/安全总监
```

背景项目：三河市保障性租赁住房项目（公开招标信息提炼，12栋一类高层住宅+10栋多层公共建筑，约14.75万㎡）。分包单位、人员、制度为演示用合理虚构，已在文档中标注。

## 技术栈

| 层 | 选型 | 说明 |
|---|---|---|
| Agent编排 | **LangGraph** 状态机 | 抽取→追问判定→检索→定级→匹配→工单草稿，节点可独立替换引擎 |
| 后端 | **FastAPI** + SQLAlchemy 2.0 | REST API，多层角色权限 |
| 依赖管理 | **uv** + `pyproject.toml` / `uv.lock` | 一条 `uv sync` 重建环境，版本锁定可复现 |
| 前端 | **Vue3 + Element Plus + ECharts** | 四角色工作台、AI对话、数据看板 |
| 数据库 | **MySQL 8.4**（阿里云） | SQLite本地兜底开关，演示断网不翻车 |
| 知识库 | 规范条款 + 轻量向量检索 | 真实模式=通义text-embedding-v4余弦；模拟模式=bigram相似度 |
| 大模型 | 通义千问（DashScope兼容模式） | qwen-flash文本 / qwen-vl-plus图片 / qwen3-asr-flash语音 |

**双模式设计**：`MOCK_MODE=true`（默认）时全部AI能力走内置模拟引擎，**零API消耗**；
填入 `DASHSCOPE_API_KEY` 并将 `MOCK_MODE` 改为 `false` 即切换真实AI，前端横幅自动显示当前引擎。

## 快速启动（本地演示）

**最简方式（推荐，Windows）**：下载/克隆本仓库后，双击根目录 **`一键启动.bat`** —— 自动创建环境、安装依赖、启动服务并打开浏览器（首次约1-2分钟，之后秒开）。无需 Node、无需 MySQL、无需任何 API Key：默认使用内置模拟引擎 + 本地 SQLite 演示库，开箱即用。若机器上没装 uv，脚本会用 pip 自动装一个。

<details>
<summary>手动命令行方式（macOS/Linux 或想看过程）</summary>

后端依赖由 **uv** 管理（配置在 `backend/pyproject.toml`，精确版本锁定在 `backend/uv.lock`）。
还没装 uv 的话先装一次：

```bash
# 任选其一
pip install uv
# Windows:  powershell -c "irm https://astral.sh/uv/install.ps1 | iex"
# macOS/Linux:  curl -LsSf https://astral.sh/uv/install.sh | sh
```

```bash
# 1. 后端（首次运行自动建表+灌入演示数据，数据库不可达时自动回退SQLite）
cd backend
uv sync                                   # 按 uv.lock 建 .venv 并装齐依赖（需 Python 3.11+）
uv run python -m uvicorn app.main:app --port 8000

# 2. 浏览器打开 http://127.0.0.1:8000 （前端构建产物已随仓库提供，无需Node）
#    如需修改前端：cd frontend && npm install && npm run dev（开发模式，5173端口）
```

常用命令：`uv add <包名>` 加依赖、`uv remove <包名>` 删依赖、`uv run python xxx.py` 在环境里跑脚本（都会同步更新 `uv.lock`，记得一并提交）。
</details>

**接入真实 AI / 云端数据库**：复制 `backend/.env.example` 为 `backend/.env` 填入配置；或启动后在网页左侧菜单「系统设置」里直接填 API Key、选模型（保存即生效）。默认模拟引擎不消耗任何额度，断网可演示。

### 开启邮箱注册（可选，不配则无法注册新账号）

默认未配置邮箱，注册接口直接返回"邮件服务暂未配置"，**只能用下面的演示账号登录**。要开放邮箱验证码注册，在 `backend/.env` 填这几项后重启后端（配置在启动时读取一次，改完必须重启）：

| 字段 | 填什么 |
|---|---|
| `SMTP_HOST` | QQ邮箱填 `smtp.qq.com`；163邮箱填 `smtp.163.com` |
| `SMTP_PORT` | `465`（SSL，推荐） |
| `SMTP_USER` | 你的**完整邮箱地址**，如 `123456789@qq.com`（不是纯QQ号） |
| `SMTP_PASS` | **授权码**（16位字母，不是邮箱登录密码） |
| `SMTP_FROM` | 留空即可，程序自动用 `SMTP_USER`（填成与它不同的地址会被服务商拒信） |

**QQ邮箱授权码怎么拿**：浏览器登录 `mail.qq.com` → 顶部「设置」→「账号」→ 找到「POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务」→ 开启「IMAP/SMTP服务」→ 按提示用绑定手机发送指定短信 → 弹出 16 位授权码（**只显示一次，先复制存好**）。若之前开过，点「生成授权码」可重新获取。填登录密码而非授权码会认证失败。

**验证是否配成功**（能收到邮件即成功）：

```bash
cd backend
uv run python -c "from app.services.mailer import send_code_email; send_code_email('你的邮箱@qq.com','123456')"
```

注意邮件是**真实发送**的（`MOCK_MODE` 只管 AI 能力，不影响邮箱），QQ 免费邮箱有每日发信额度，演示时别反复点。

## 队友/评委如何访问

- **同一局域网**：发起人用 `一键启动.bat` 启动（已监听 0.0.0.0），队友访问 `http://发起人IP:8000`（首次启动请在 Windows 防火墙弹窗点"允许"）；局域网 IP 可用 `ipconfig` 查看
- **公网访问**：部署到服务器，或本机用 cpolar/natapp 等内网穿透生成临时公网链接
- **各测各的**：克隆仓库各自本地跑，AI Key 在「系统设置」页各填各的

## 演示账号（密码均为 `zhuan@123`）

| 角色 | 账号 | 说明 |
|---|---|---|
| 安全员 张明 | `zhangmin` | 上报隐患、审核派单、复查闭环 |
| 安全总监 李强 | `liqiang` | 看板/周报；重大风险工单须由其复核 |
| 项目经理 王建国 | `wangjianguo` | 看板/周报 |
| 分包责任人（6人） | `zeren01`~`zeren06` | 接收工单、整改、提交复查 |

## 工单状态机

```
上报 → AI生成草稿 → [待审核] --安全员审核通过--> [已派发] --责任人--> [整改中]
                    |                              |                     |
                    驳回                     延期/超期预警           责任人提交
                    ↓                              ↓                     ↓
                 [已驳回]                      （催办）              [待复查] --安全员复查合格--> [已闭环]
                                                              |不合格退回→ 整改中
```

- **重大风险工单**须由安全总监（而非安全员）复核后派单；
- 超期工单在所有列表/看板自动标红预警；
- 每一步流转写入 `order_events`，全程可追溯。

## 知识库

`backend/knowledge/regulations.json`：49条精选条款（GB 55034-2022强制性规范、JGJ 80-2016高处作业、
JGJ 130-2011脚手架、GB 50720-2011消防、JGJ 46-2005临时用电、JGJ 196-2010塔吊、JGJ 215-2010升降机、
GB 50497-2019基坑监测、项目安全管理制度）。条款为要点精简演示版，正式使用以现行有效文本为准。

## 项目结构

```
zhuan-cloud/
├── backend/
│   ├── app/
│   │   ├── agents/        # LangGraph流水线、抽取/定级/匹配引擎、LLM抽象
│   │   ├── rag/           # 知识检索（向量/关键词双模式）
│   │   ├── routers/       # auth/meta/reports/orders/chat/stats/weekly/media
│   │   ├── services/      # 语音转写、图片识别、周报生成、Word导出
│   │   ├── models.py      # 9张表：users/subcontractors/zones/reports/work_orders/order_events/regulations/weekly_reports/projects
│   │   └── seed.py        # 幂等演示数据：项目/分包/人员/分区/条款/六周历史工单
│   ├── knowledge/         # 规范条款知识库
│   ├── pyproject.toml     # 后端依赖声明（uv）
│   └── uv.lock            # 依赖精确版本锁定
├── frontend/              # Vue3 + Element Plus + ECharts
└── scripts/               # 一键启动脚本
```

## 安全提示

`.env` 含数据库口令，已在 `.gitignore` 排除，**严禁提交**。演示环境数据库请勿使用生产口令。
