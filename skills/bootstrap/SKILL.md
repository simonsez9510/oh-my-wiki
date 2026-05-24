---
name: bootstrap
description: 빈 옵시디언 vault에 LLM Wiki 시드 자동 구축. 직무 한 번 묻고 폴더·일관성카드·페르소나 properties·1차/2차 빌드 자동 실행. kepano 5스킬 + 옵시디언 CLI 본체(1.12.7+) 의존. 트리거 — "oh my wiki", "vault 부트스트랩", "지식관리시스템 셋업", "옵시디언 빈 vault 시작".
---

# Oh My Wiki — bootstrap

원성묵 원장 2026년 상반기 한 회계법인 강의 정점 50분 흐름을 한 명령으로 재현합니다.

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
   - **부모 vault 하위 주의** — 신규 경로가 이미 등록된 vault 폴더 안이면, 부모 vault에서도 노트가 모두 보임 (옵시디언 일반 동작). 독립 그래프뷰가 필요하면 활성 vault를 신규 vault로 전환해야 의도된 모양 확인 가능. 강의 데모 시 헷갈리는 자리 — 사용자에게 한 줄 안내.

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

- **`_meta/일관성카드.md`** ← `templates/consistency_card.md` 내용 그대로 (frontmatter 4축 박힌 상태)
- **`_meta/페르소나.md`** ← 사용자 직무 + 어휘 매핑 + 4축 properties 형식 박음

### 노트 생성 방법 — 파일시스템 직접 권장

```
# PowerShell / shell write 도구 / LLM 호스트의 Write 등
<vault>/_meta/일관성카드.md 직접 박기
<vault>/_meta/페르소나.md 직접 박기
```

**옵시디언 CLI `create path=... content=...` 명령은 권장 안 함** — 한국어 멀티라인 컨텐츠의 escape(`\n`·따옴표·yaml frontmatter)가 까다로워 실수 빈발. 파일시스템 직접 박은 후 옵시디언 CLI는 다음 단계 *후속 작업*(reload·open·property:set·rename)에만 사용.

박은 후 vault 인덱싱:

```
obsidian reload
```

## 4단계 · vault 리프레시 (L2)

```powershell
.\scripts\postsetup_refresh.ps1 -VaultName "<vault-name>" -KeyNote "_meta/일관성카드.md"
```

옵시디언 GUI에서 일관성카드 노트 자동 열림 + 그래프뷰 자동 열림.

사용자에게 한 줄 출력: **"_meta/일관성카드.md를 확인하시고, raw/ 폴더에 자료 5~10개 넣으셨으면 '1차 빌드' 입력하세요."**

## 5단계 · 1차 빌드 (사용자가 "1차 빌드" 입력 시)

`prompts/first_build.md` 로드 → 페르소나 변수 치환 → Claude Code가 raw/ 자료를 위키 노트로 자동 변환.

### raw 자료 분포 권장 (강의 데모용)

raw/ 폴더에 자료가 없거나 한 종류만 있으면 그래프뷰 구조가 안 보임. 강의·데모용 자료 권장 분포:

| 종류 | 권장 비율 | 분류 행선지 |
|---|---|---|
| 사례 자료 (특정 {who_label}·프로젝트·건) | 4~5개 | `{folder_who}/` |
| 기준·근거 자료 ({topic_label}·이론·정책) | 3~4개 | `{folder_topic}/` |
| 합계 | 7~9개 | — |

사례가 많아야 *사례 → 기준* 단방향 그래프 hub 구조가 시각적으로 명료. 사용자 본인 raw 자료가 부족하면 직무 도메인에 맞는 demo seed 5~7개를 LLM이 직접 박는 것도 옵션 — 단 데모임을 명시.

### 노트 생성 — 파일시스템 직접

마찬가지로 옵시디언 CLI `create` 대신 파일시스템 직접 박기. CLI는 reload·open·property:set만.

빌드 완료 후 `_meta/1차빌드_보고.md` 출력 + 다음 단계 안내.

## 6단계 · 2차 빌드 점검 표 (사용자가 "진행" 입력 시)

`prompts/second_build.md` 로드 → 페르소나 변수 치환 → 일관성 카드 5규칙 위반 항목을 `_meta/2차빌드_점검.md` 표로 출력 (아직 변경 미적용).

사용자에게: **"점검 표 확인하셨으면 '진행' 한 번 더 입력하세요."**

## 7단계 · 2차 빌드 적용

사용자 "진행" 확인 후:

1. 점검 표대로 각 노트에 properties·제목·첫 줄 요약·위키링크 적용
   - properties 변경·rename은 옵시디언 CLI 사용 OK (`property:set`·`rename`)
   - 본문 통째 다시 박는 케이스(frontmatter 추가·"참고:" 섹션 정리 등)는 파일시스템 직접
2. `obsidian reload`
3. `obsidian command id=graph:open` — 실패 시 1~2초 후 재시도 (트러블슈팅 참고)
4. `_meta/2차빌드_적용보고.md` 출력

## 보호 규칙

- `raw/` 폴더 원본은 **절대** 수정 X
- 사용자 동의 없이 본문 자동 변경 X
- 헬스체크 실패 시 진행 멈춤 (CLI 없으면 명시적 fallback 모드 안내 — L1만 작동, L2 생략)
- 점검 표 출력 후 사용자 "진행" 없이 일괄 적용 X
- 직무 매핑 모호하면 사용자에게 직접 묻기 (추측 X)
- **부모 vault 하위 경로 주의** — vault 활성화 안 해도 부모 vault에서 노트 보임. 사용자에게 명시 (1단계 참고)

## 옵시디언 CLI 명령 cheatsheet (이 스킬이 호출하는 것)

> **권장 분업** — 컨텐츠 생성·본문 통째 박기는 **파일시스템 직접**, 옵시디언 CLI는 reload·open·property:set·rename·command 같은 *vault 상태 조작*에만 사용. 한국어 멀티라인 escape 함정 회피 + 코드 단순화.

> **중요 — `vault=<name>` 옵션 제한사항** (PoC 검증에서 발견)
>
> `vault=` 옵션은 조회 명령(`files`·`folders`·`vault info=...`)에만 안전.
> *액션 명령*(`open`·`command`·`create` 등)과 결합하면 파서가 "Command not found" 응답.
> 따라서 액션은 **활성 vault 기준으로만** 호출. 다른 vault 작업 시 옵시디언 GUI에서 vault 전환 후 진행.

| 동작 | 명령 | vault= 옵션 가능 | 권장 |
|---|---|---|---|
| 헬스체크 | `obsidian version` | — | ✅ |
| vault 리스트 | `obsidian vaults` | — | ✅ |
| 활성 vault 경로 | `obsidian vault info=path` | — | ✅ |
| 활성 vault 이름 | `obsidian vault info=name` | — | ✅ |
| 파일 리스트 (다른 vault) | `obsidian vault=<name> files` | ✅ | ✅ |
| 폴더 리스트 (다른 vault) | `obsidian vault=<name> folders` | ✅ | ✅ |
| 노트 생성 (활성 vault) | `obsidian create path=<path> content=<text>` | ❌ | ⚠️ 한국어 멀티라인 escape 어려움 — **파일시스템 직접 권장** |
| 노트 열기 (활성 vault) | `obsidian open path=<path>` | ❌ | ✅ |
| properties 박기 (활성 vault) | `obsidian property:set name=<key> value=<val> path=<file>` | ❌ | ✅ |
| 노트 추가 (활성 vault) | `obsidian append path=<path> content=<text>` | ❌ | ⚠️ 짧은 한 줄만 |
| 노트 rename (활성 vault) | `obsidian rename path=<old> name=<new>` | ❌ | ✅ |
| vault 리로드 (활성 vault) | `obsidian reload` | ❌ | ✅ |
| 그래프뷰 열기 (활성 vault) | `obsidian command id=graph:open` | ❌ | ✅ (재시도 함정 — 트러블슈팅 참고) |
| 활성 탭 확인 | `obsidian tabs` | — | ✅ |
| 사용 가능 command 검색 | `obsidian commands filter=<prefix>` | — | ✅ |

### 인자 형식 — `key=value` (PoC 발견)

옵시디언 CLI는 **`key=value` 형식**이며 `--flag value`나 `-flag` 형식은 사용하지 않음.
공백 포함 시 따옴표: `name="My Note"`. 멀티라인은 `\n`·`\t` 이스케이프 — *짧은 한 줄에만 권장*.

## 트러블슈팅

| 증상 | 원인 | 해결 |
|---|---|---|
| `Command line interface is not enabled` | CLI 토글 OFF | Settings → General → Advanced 토글 ON |
| `vault '<name>' not found` | 옵시디언 GUI에 vault 미등록 | "Open folder as vault"로 등록 |
| 노트 만들어졌는데 옵시디언에 안 보임 | vault 리로드 안 됨 | `obsidian reload` 직접 실행 |
| 한국어 폴더명 깨짐 | PowerShell 인코딩 | `chcp 65001` 후 재시도 |
| `obsidian command id=graph:open` → `Command "command" not found. It may require a plugin to be enabled.` | vault 활성화 직후 첫 호출, graph plugin 로드 지연 | 1~2초 대기 후 재시도. 정상 응답 `Executed: graph:open` |
| `obsidian open path=...` → `File not found` | reload 직후 file index sync 지연 | 1~2초 대기 후 재시도. 또는 `obsidian reload` 한 번 더 |
| 새 vault인데 노트가 다른 vault에도 보임 | 새 vault 폴더가 부모 vault 하위에 있음 | 옵시디언 일반 동작. 독립 그래프뷰 원하면 활성 vault를 새 vault로 전환 |

---

*v1.1 (2026-05-24) · 1인 자산운용사 부트캠프 vault PoC E2E 검증 후 패치 — 파일시스템 직접 박기 권장 · graph:open 재시도 함정 · 부모 vault 하위 케이스 · demo seed 분포 가이드.*
*v1.0 (2026-05) · 원성묵 원장 2026년 상반기 한 회계법인 강의 IP 패키지 · PoC E2E 검증 후 공개 릴리즈.*
*GitHub: https://github.com/simonsez9510/oh-my-wiki*
