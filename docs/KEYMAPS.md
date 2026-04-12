# Keymaps 치트시트

## Neovim

Leader: `Space`

### 기본

| 키 | 모드 | 동작 |
|---|---|---|
| `jk` | Insert | Esc |
| `<leader>w` | Normal | 저장 |
| `<leader>q` | Normal | 닫기 |
| `<Esc>` | Normal | 검색 하이라이트 해제 |

### 창 이동

| 키 | 동작 |
|---|---|
| `C-h/j/k/l` | 창 이동 (좌/하/상/우) |
| `C-Up/Down/Left/Right` | 창 크기 조절 |

### 버퍼

| 키 | 동작 |
|---|---|
| `S-h` | 이전 버퍼 |
| `S-l` | 다음 버퍼 |

### Claude Code 연동

| 키 | 모드 | 동작 |
|---|---|---|
| `<leader>yr` | Visual | 상대경로 + 코드 복사 |

### Visual 모드

| 키 | 동작 |
|---|---|
| `J` / `K` | 라인 이동 (아래/위) |
| `<` / `>` | 들여쓰기 (선택 유지) |
| `<leader>p` | 붙여넣기 (레지스터 보존) |

---

## tmux

Prefix: `C-a`

### 기본

| 키 | 동작 |
|---|---|
| `prefix + \|` | 수직 분할 |
| `prefix + -` | 수평 분할 |
| `prefix + c` | 새 윈도우 |
| `prefix + r` | 설정 리로드 |

### 패인 이동/크기

| 키 | 동작 |
|---|---|
| `prefix + h/j/k/l` | 패인 이동 |
| `prefix + H/J/K/L` | 패인 크기 조절 |

### Claude Code

| 키 | 동작 |
|---|---|
| `prefix + C` | Claude Code 패인 열기 (우측 40%) |

### 세션

| 키 | 동작 |
|---|---|
| `prefix + C-s` | 세션 저장 (resurrect) |
| `prefix + C-r` | 세션 복원 (resurrect) |
| `prefix + d` | 디태치 |
| `prefix + [` | 복사 모드 (vi 키바인딩) |
