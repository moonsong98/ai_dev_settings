# ADR-001: lazy.nvim 선택

## 상태: 확정

## 날짜: 2026-04-11

## 맥락

Neovim 플러그인 매니저 선택이 필요.
주요 후보: lazy.nvim, packer.nvim, vim-plug

## 결정

**lazy.nvim** 을 사용한다.

## 근거

- **lazy-lock.json**: 플러그인 버전을 파일로 고정하여 머신 간 동일 환경 재현
- **lazy loading**: 기본적으로 지연 로딩, 시작 시간 최소화
- **선언적 설정**: 각 플러그인이 독립 파일로 관리 가능 (`plugins/*.lua`)
- **활발한 유지보수**: 2026년 기준 Neovim 커뮤니티 표준
- packer.nvim은 유지보수 중단됨
- vim-plug은 Lua 네이티브가 아님

## 영향

- 플러그인 추가/변경 시 `lazy-lock.json` 도 함께 커밋해야 함
- `checker.enabled = false` 로 자동 업데이트 비활성화 → 수동 관리
