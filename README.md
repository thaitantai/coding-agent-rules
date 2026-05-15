# AI Rules Kit

Bộ quy tắc production cho coding agents theo hướng: native adapter ngắn, agent tự suy luận task như reviewer, rồi chỉ load rule module và reference cần thiết.

## Mục tiêu thiết kế

- Giữ khả năng auto-load native của từng tool.
- Tránh nhồi toàn bộ rule dài vào context mỗi request.
- Bắt agent chọn rule dựa trên intent, file sẽ chạm, và rủi ro nếu sửa sai.
- Giữ `.ai/rules/*.md` là nguồn rule chi tiết, dễ mở rộng.
- Cho phép agent tham khảo các repo mẫu trưởng thành như knowledge base, nhưng không copy máy móc.

## Agents được hỗ trợ

| Agent | Native adapter |
|---|---|
| OpenAI Codex | `AGENTS.md` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Claude Code | `.claude/CLAUDE.md` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Aider | `CONVENTIONS.md` |

## Cấu trúc

```text
.ai/
├── agent-core.md                 # Core protocol luôn được đọc
├── rules-index.md                # Mapping intent/files/risk -> rule modules
├── reference-index.md            # Repo mẫu để tham khảo khi cần judgment
├── manifest.json                 # Danh sách file để installer tải từ GitHub
└── rules/                        # Rule chi tiết, chỉ load khi liên quan
    ├── 001-general.md
    ├── 002-file-structure.md
    ├── 003-code-quality.md
    ├── 004-typescript.md
    ├── 005-testing.md
    ├── 006-git.md
    ├── 007-security.md
    ├── 008-performance.md
    ├── 009-api-design.md
    └── 010-environment.md

AGENTS.md                         # Native adapter cho Codex
.cursorrules                      # Native adapter cho Cursor
.windsurfrules                    # Native adapter cho Windsurf
.claude/CLAUDE.md                 # Native adapter cho Claude Code
.github/copilot-instructions.md   # Native adapter cho GitHub Copilot
CONVENTIONS.md                    # Native adapter cho Aider
sync-rules.ps1                    # Script sync adapter
install-rules.ps1                 # Installer de tai rules tu GitHub
package.json                      # Cho phep cai bang npx tu GitHub
bin/ai-rules.js                   # CLI cai dat agent rules
```

## Cách hoạt động

Native adapter không chứa toàn bộ rule. Nó chỉ bootstrap agent:

```text
Native adapter
      ↓
.ai/agent-core.md
      ↓
Agent suy luận intent + touched files + risk
      ↓
.ai/rules-index.md
      ↓
Chỉ load rule modules liên quan trong .ai/rules/
      ↓
.ai/reference-index.md khi cần repo mẫu để tăng chất lượng judgment
```

Ví dụ prompt "fix lỗi login" không cần user viết chuẩn. Agent phải suy luận đây là auth flow, có thể chạm API/session/security/tests, rồi load rule tương ứng.

Nếu task cần quyết định kiến trúc hoặc chất lượng code sâu hơn, agent có thể đọc `.ai/reference-index.md` để tham khảo repo mẫu. Reference chỉ giúp trả lời "good pattern trông như thế nào", không thay thế local rules.

## Rule modules

| File | Nội dung chính |
|---|---|
| `001-general.md` | Hành vi agent, task execution, code philosophy, file ops |
| `002-file-structure.md` | Chuẩn cây thư mục cho Node/Next.js/Python/Monorepo |
| `003-code-quality.md` | Functions, naming, error handling, async, imports |
| `004-typescript.md` | Strict mode, generics, nullability, Zod validation |
| `005-testing.md` | AAA pattern, unit/integration/E2E, mocking |
| `006-git.md` | Branch naming, Conventional Commits, PR standards |
| `007-security.md` | Secrets, input validation, auth, API security |
| `008-performance.md` | DB queries, caching, frontend, background jobs |
| `009-api-design.md` | REST conventions, versioning, response shapes |
| `010-environment.md` | Env vars, Docker, CI/CD, health checks, migrations |

## Reference knowledge

| Reference | Dùng cho |
|---|---|
| Bulletproof React | React/TypeScript architecture, feature-based structure, API/state/testing boundaries |
| Node.js Best Practices | Node.js backend architecture, layered components, error handling, config, security, operations |
| Clean Code JavaScript | Naming, function design, readability, JS/TS refactoring, async/error handling |

References nằm trong `.ai/reference-index.md`. Chúng là advisory knowledge, không phải rule bắt buộc.

## Cách dùng

### Cách 1: Copy local

```powershell
Copy-Item -Recurse .ai your-project\
Copy-Item sync-rules.ps1 your-project\
```

### 2. Chạy sync lần đầu

```powershell
Set-Location your-project
powershell -ExecutionPolicy Bypass -File sync-rules.ps1
```

### Cách 2: Cài bằng npx

Đây là cách ngắn nhất cho project mới. Chạy trong root project cần cài rules:

```powershell
npx github:thaitantai/coding-agent-rules codex
```

Chọn agent khác bằng tham số đầu tiên:

```powershell
npx github:thaitantai/coding-agent-rules claude
npx github:thaitantai/coding-agent-rules cursor
npx github:thaitantai/coding-agent-rules all
```

Ghi đè file đã tồn tại:

```powershell
npx github:thaitantai/coding-agent-rules codex --force
```

Cài vào thư mục khác:

```powershell
npx github:thaitantai/coding-agent-rules codex --target ./my-project
```

CLI luôn cài `.ai/` vì native adapter cần các file core/rules/index chung. Agent-specific chỉ quyết định native adapter nào được cài:

| Agent | File được cài |
|---|---|
| `codex` | `AGENTS.md` |
| `cursor` | `.cursorrules` |
| `windsurf` | `.windsurfrules` |
| `claude` | `.claude/CLAUDE.md` |
| `copilot` | `.github/copilot-instructions.md` |
| `aider` | `CONVENTIONS.md` |
| `all` | tất cả native adapters |

Không dùng `--force` thì CLI sẽ bỏ qua file đã tồn tại để tránh overwrite.

### Cách 3: Cài bằng PowerShell raw URL

Dùng cách này nếu máy không dùng `npx`. Raw base URL:

```text
https://raw.githubusercontent.com/thaitantai/coding-agent-rules/main
```

Ví dụ cài rules cho Codex vào root project hiện tại:

```powershell
$base = "https://raw.githubusercontent.com/thaitantai/coding-agent-rules/main"
Invoke-WebRequest "$base/install-rules.ps1" -OutFile install-rules.ps1
powershell -ExecutionPolicy Bypass -File install-rules.ps1 -Agent codex -SourceBaseUrl $base -InstallPath . -Force
```

Chỉ định agent khác bằng `-Agent`:

```powershell
powershell -ExecutionPolicy Bypass -File install-rules.ps1 -Agent claude -SourceBaseUrl $base -InstallPath . -Force
powershell -ExecutionPolicy Bypass -File install-rules.ps1 -Agent cursor -SourceBaseUrl $base -InstallPath . -Force
powershell -ExecutionPolicy Bypass -File install-rules.ps1 -Agent all -SourceBaseUrl $base -InstallPath . -Force
```

### Chỉnh rule

Chỉnh một trong các file nguồn:

```text
.ai/agent-core.md
.ai/rules-index.md
.ai/reference-index.md
.ai/rules/*.md
```

Sau đó chạy lại:

```powershell
powershell -ExecutionPolicy Bypass -File sync-rules.ps1 -Agent all
```

Không chỉnh trực tiếp các native adapter vì chúng là file sinh ra.

## Thêm rule mới

Tạo file mới trong `.ai/rules/` với số thứ tự tiếp theo:

```text
.ai/rules/011-react-native.md
.ai/rules/012-graphql.md
.ai/rules/013-observability.md
```

Sau đó cập nhật `.ai/rules-index.md` để agent biết khi nào phải load rule mới.

## Workflow

```text
Chỉnh .ai/agent-core.md, .ai/rules-index.md, .ai/reference-index.md, hoặc .ai/rules/*.md
        ↓
Chạy sync-rules.ps1 -Agent all
        ↓
Sinh native adapter ngắn cho từng agent
        ↓
Agent tự load rule chi tiết theo intent/files/risk khi làm việc
```
