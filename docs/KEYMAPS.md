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

### 파일 탐색기 (oil.nvim)

| 키 | 모드 | 동작 |
|---|---|---|
| `-` | Normal | 현재 버퍼 디렉토리 열기 (oil 안에서는 상위로 이동) |
| `<leader>e` | Normal | 같은 동작 (e = explorer) |

oil 버퍼 안에서:
- `<CR>` 파일 열기 / 디렉토리 진입
- 한 줄 추가하면 새 파일/디렉토리, `dd` 로 삭제, `cw` 로 이름 변경
- `:w` 저장 → 디스크에 변경 적용
- `q` 닫기

### Git (gitsigns.nvim)

| 키 | 모드 | 동작 |
|---|---|---|
| `]h` / `[h` | Normal | 다음 / 이전 변경 hunk |
| `<leader>hp` | Normal | 변경 미리보기 (floating) |
| `<leader>hd` | Normal | diff 보기 (현재 vs HEAD) |
| `<leader>hb` | Normal | 라인 blame (전체 정보 floating) |
| `<leader>tb` | Normal | 라인 blame 인라인 토글 |
| `<leader>hs` | Normal | hunk stage (= git add) |
| `<leader>hr` | Normal | hunk reset (변경 되돌리기) |
| `<leader>hS` / `<leader>hR` | Normal | 버퍼 전체 stage / reset |
| `<leader>td` | Normal | 삭제된 라인 인라인 표시 토글 |
| `ih` | Operator/Visual | hunk 텍스트 오브젝트 (`vih`, `dih`, `yih` 등) |

### Telescope (퍼지 파인더)

| 키 | 동작 |
|---|---|
| `<leader>ff` | 파일 찾기 (fd) |
| `<leader>fg` | 내용 검색 — live grep (rg) |
| `<leader>fs` | 커서 위 단어 grep |
| `<leader>fr` | 최근 연 파일 (oldfiles) |
| `<leader>fb` | 열린 버퍼 전환 |
| `<leader>fh` | vim help 검색 |
| `<leader>fk` | 키맵 검색 |
| `<leader>fc` | 명령어 검색 |
| `<leader>gb` | git 브랜치 |
| `<leader>gs` | git 변경 파일 |
| `<leader>gc` | git 커밋 로그 |
| `<leader>f.` | 직전 picker 재실행 |

telescope picker 안에서:
- `<C-n>` / `<C-p>` 또는 `<C-j>` / `<C-k>` 결과 이동
- `<CR>` 선택
- `<C-x>` 가로 분할로 열기, `<C-v>` 세로 분할, `<C-t>` 새 탭
- `<C-/>` insert 모드에서 도움말, `?` normal 모드에서

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
