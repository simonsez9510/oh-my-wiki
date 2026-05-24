---
name: bootstrap
description: 빈 옵시디언 vault에 LLM Wiki 시드 자동 구축. 직무 한 번 묻고 폴더·일관성카드·페르소나 properties·1차/2차 빌드 자동 실행. kepano 5스킬 + 옵시디언 CLI 본체(1.12.7+) 의존. 트리거 — "vault 부트스트랩", "지식관리시스템 셋업", "옵시디언 빈 vault 시작", "won-vault-bootstrap".
---

# won-vault-bootstrap

원성묵 원장 선명회계법인 강의(2026-05-21) 정점 50분 흐름을 한 명령으로 재현합니다.

## 의존성

- **옵시디언 인스톨러 1.12.7+** (Microsoft Store 버전 ✗)
- **옵시디언 CLI 토글 ON** — Settings → General → **Advanced** → "Command line interface"
- **kepano 5스킬 설치** — `~/.claude/skills/` 또는 vault `.claude/skills/`에 obsidian-markdown·obsidian-bases·json-canvas·obsidian-cli·defuddle 5개 존재

## 0단계 · 헬스체크 (필수 선행)

```powershell
.\scripts\healthcheck.ps1
```

Exit 0 아니면 진행 멈춤. 안내 메시지대로 해결 후 재실행.

## 1단계 · 사용자 입력 수집

다음 두 가지 묻기:

1. **직무** — `[회계사 / 변호사 / 매체운영자 / 연구자 / 기타(직접입력)]`
2. **대상 vault** — `obsidian vaults` 결과 보여주고 이름 또는 신규 경로 받기
   - 신규 경로면 폴더 생성 + 옵시디언 GUI에서 "Open folder as vault" 안내

## 2단계 · 페르소나 로드

직무 → 매칭되는 페르소나 템플릿 로드:

| 직무 | 템플릿 파일 |
|---|---|
| 회계사 | `templates/persona_accountant.md` |
| 변호사 | `templates/persona_lawyer.md` |
| 매체운영자 | `templates/persona_journalist.md` |
| 연구자 | `templates/persona_researcher.md` |
| 기타 | 4종 중 사용자가 base로 고를 것 선택 + 어휘 매핑 직접 입력 |

페르소나에서 `{persona}` `{who_label}` `{topic_label}` `{kind_examples}` `{folder_who}` `{folder_topic}` 변수값 추출.

## 3단계 · vault 폴더 구조·일관성카드·페르소나 박기 (L1)

페르소나 템플릿의 "폴더 구조" 섹션 그대로 폴더 생성:

```
<vault>/
├── raw/
├── _meta/
├── <{folder_who}>/
├── <{folder_topic}>/
└── 캔버스/
```

핵심 노트 자동 생성:

- **`_meta/일관성카드.md`** ← `templates/consistency_card.md` 내용 그대로
- **`_meta/페르소나.md`** ← 사용자 직무 + 어휘 매핑 + 4축 properties 형식 박음

옵시디언 CLI 활용:

```
obsidian vault=<vault-name> create path=_meta/일관성카드.md content="<consistency_card.md 내용>"
obsidian vault=<vault-name> create path=_meta/페르소나.md content="<persona content>"
```

## 4단계 · vault 리프레시 (L2)

```powershell
.\scripts\postsetup_refresh.ps1 -VaultName "<vault-name>" -KeyNote "_meta/일관성카드.md"
```

옵시디언 GUI에서 일관성카드 노트 자동 열림 + 그래프뷰 자동 열림.

사용자에게 한 줄 출력: **"_meta/일관성카드.md를 확인하시고, raw/ 폴더에 자료 5~10개 넣으셨으면 '1차 빌드' 입력하세요."**

## 5단계 · 1차 빌드 (사용자가 "1차 빌드" 입력 시)

`prompts/first_build.md` 로드 → 페르소나 변수 치환 → Claude Code가 raw/ 자료를 위키 노트로 자동 변환.

빌드 완료 후 `_meta/1차빌드_보고.md` 출력 + 다음 단계 안내.

## 6단계 · 2차 빌드 점검 표 (사용자가 "진행" 입력 시)

`prompts/second_build.md` 로드 → 페르소나 변수 치환 → 일관성 카드 5규칙 위반 항목을 `_meta/2차빌드_점검.md` 표로 출력 (아직 변경 미적용).

사용자에게: **"점검 표 확인하셨으면 '진행' 한 번 더 입력하세요."**

## 7단계 · 2차 빌드 적용

사용자 "진행" 확인 후:

1. 점검 표대로 각 노트에 properties·제목·첫 줄 요약·위키링크 적용
2. `obsidian vault=<vault> reload`
3. `obsidian vault=<vault> command id=graph:open`
4. `_meta/2차빌드_적용보고.md` 출력

## 보호 규칙

- `raw/` 폴더 원본은 **절대** 수정 X
- 사용자 동의 없이 본문 자동 변경 X
- 헬스체크 실패 시 진행 멈춤 (CLI 없으면 명시적 fallback 모드 안내 — L1만 작동, L2 생략)
- 점검 표 출력 후 사용자 "진행" 없이 일괄 적용 X
- 직무 매핑 모호하면 사용자에게 직접 묻기 (추측 X)

## 옵시디언 CLI 명령 cheatsheet (이 스킬이 호출하는 것)

> **중요 — `vault=<name>` 옵션 제한사항** (PoC 2026-05-24 발견)
>
> `vault=` 옵션은 조회 명령(`files`·`folders`·`vault info=...`)에만 안전.
> *액션 명령*(`open`·`command`·`create` 등)과 결합하면 파서가 "Command not found" 응답.
> 따라서 액션은 **활성 vault 기준으로만** 호출. 다른 vault 작업 시 옵시디언 GUI에서 vault 전환 후 진행.

| 동작 | 명령 | vault= 옵션 가능 |
|---|---|---|
| 헬스체크 | `obsidian version` | — |
| vault 리스트 | `obsidian vaults` | — |
| 활성 vault 경로 | `obsidian vault info=path` | — |
| 활성 vault 이름 | `obsidian vault info=name` | — |
| 파일 리스트 (다른 vault) | `obsidian vault=<name> files` | ✅ |
| 폴더 리스트 (다른 vault) | `obsidian vault=<name> folders` | ✅ |
| 노트 생성 (활성 vault) | `obsidian create path=<path> content=<text>` | ❌ |
| 노트 열기 (활성 vault) | `obsidian open path=<path>` | ❌ |
| properties 박기 (활성 vault) | `obsidian property:set name=<key> value=<val> path=<file>` | ❌ |
| 노트 추가 (활성 vault) | `obsidian append path=<path> content=<text>` | ❌ |
| vault 리로드 (활성 vault) | `obsidian reload` | ❌ |
| 그래프뷰 열기 (활성 vault) | `obsidian command id=graph:open` | ❌ |
| 활성 탭 확인 | `obsidian tabs` | — |
| 사용 가능 command 검색 | `obsidian commands filter=<prefix>` | — |

### 인자 형식 — `key=value` (PoC 발견)

옵시디언 CLI는 **`key=value` 형식**이며 `--flag value`나 `-flag` 형식은 사용하지 않음.
공백 포함 시 따옴표: `name="My Note"`. 멀티라인은 `\n`·`\t` 이스케이프.

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `Command line interface is not enabled` | CLI 토글 OFF | Settings → General → Advanced 토글 ON |
| `vault '<name>' not found` | 옵시디언 GUI에 vault 미등록 | "Open folder as vault"로 등록 |
| 노트 만들어졌는데 옵시디언에 안 보임 | vault 리로드 안 됨 | `obsidian reload` 직접 실행 |
| 한국어 폴더명 깨짐 | PowerShell 인코딩 | `chcp 65001` 후 재시도 |

---

*v1.0 (2026-05-24) · 원성묵 원장 선명회계법인 강의(2026-05-21) IP 패키지 · PoC E2E 검증 후 글로벌 릴리즈.*
*PoC 검증 vault: `Desktop/집필실/강의/선명회계법인_옵시디언강의/_PoC_빈vault/`*
*PoC 회고: `_PoC_빈vault/_meta/PoC_회고_2026-05-24.md`*
