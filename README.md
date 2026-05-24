# won-vault-bootstrap

> **빈 옵시디언 vault를 5분 만에 LLM Wiki 시드로 부트스트랩하는 Claude Code 플러그인.**
> 직무 한 번 묻고 폴더·일관성카드·페르소나 properties·1차/2차 빌드까지 자동 실행.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.com/code)
[![Obsidian](https://img.shields.io/badge/Obsidian-1.12.7%2B-7c3aed)](https://obsidian.md)

---

## 한 줄 소개

**원성묵 원장 선명회계법인 강의(2026-05-21) IP**를 Claude Code 플러그인으로 패키징했습니다. 강의 정점 50분 흐름(빈 vault → 폴더 셋업 → 일관성 카드 → 1차 빌드 → 2차 빌드)을 **5분**으로 압축합니다.

## 누구를 위한 것인가

| 직무 | 어휘 매핑 | 폴더 |
|---|---|---|
| **회계사** | who=클라이언트 / topic=회계기준·세무이슈 / kind=감사메모·자문메모 | 클라이언트/, 회계기준/ |
| **변호사** | who=의뢰인 / topic=쟁점·법령·판례 / kind=자문의견서·소송서면 | 의뢰인/, 판례/, 법령/ |
| **매체운영자·기자** | who=취재원 / topic=이슈·테마 / kind=기사·기획안·인터뷰메모 | 취재원/, 이슈/, 기사/ |
| **연구자** | who=프로젝트 / topic=개념·이론 / kind=논문·보고서·정책브리프 | 프로젝트/, 개념/, 출판/ |

4축 properties 표준(time·who·topic·kind)으로 모든 노트가 같은 골격을 따릅니다.

## 사전 준비

1. **옵시디언 설치** — [obsidian.md](https://obsidian.md) (**인스톨러 버전 1.12.7+** · Microsoft Store 버전 ✗)
2. **옵시디언 CLI 활성화** — `Settings → General → Advanced → "Command line interface"` 토글 ON
3. **Claude Code 설치** — [claude.com/code](https://claude.com/code)
4. **kepano 5스킬 설치** (선택, 1차/2차 빌드의 깊이를 더함):
   ```
   /plugin marketplace add kepano/obsidian-skills
   /plugin install obsidian@obsidian-skills
   ```

## 설치

Claude Code 안에서:

```
/plugin marketplace add simonsez9510/won-vault-bootstrap
/plugin install won-vault-bootstrap@won-vault-bootstrap
```

## 사용

빈 vault 만들고 옵시디언에 등록 (`Open folder as vault`)한 뒤:

```
/won-vault-bootstrap:bootstrap
```

또는 자연어로:

```
"vault 부트스트랩 실행해줘"
"지식관리시스템 셋업"
"won-vault-bootstrap 실행"
```

스킬이 차례로 묻고 진행합니다:

1. **직무 선택** — 회계사·변호사·매체운영자·연구자·기타
2. **vault 경로 확인** — 현재 활성 vault 사용
3. **폴더·일관성카드·페르소나 자동 셋업**
4. **raw/ 자료 있으면** → 1차 빌드 (위키 노트 자동 변환)
5. **2차 빌드 점검 표 확인 후** → 일관성 카드 5규칙 적용

## 데모

`demo/` 폴더에 회계사 페르소나용 더미 자료 3개가 들어있습니다:

```
demo/
├── raw/
│   ├── 01_감사메모_(주)가나_초안.md
│   ├── 02_회계기준_K-IFRS_1115_요약.md
│   └── 03_클라이언트_(주)다라_5월미팅.md
└── _meta/
    ├── 일관성카드.md
    └── 페르소나.md
```

`demo/` 폴더 전체를 본인 옵시디언 vault로 등록한 뒤 스킬을 실행하면 *강의 정점 50분*을 직접 재현할 수 있습니다.

## 아키텍처

3층 구조:

| Layer | 도구 | 역할 |
|---|---|---|
| **L1 · 파일 시스템** | Claude Code Write | 폴더 생성·노트 박기 — vault는 결국 마크다운 모음 |
| **L2 · 옵시디언 CLI** | `obsidian` 바이너리 | vault 리프레시·핵심 노트 자동 열기·그래프뷰 trigger |
| **L3 · LLM 빌드** | Claude Code + kepano 5스킬 | raw 자료 → 위키 노트 1차/2차 변환 |

L1은 반드시 작동, L2는 옵시디언 CLI 토글 ON일 때 추가 자동화, L3는 kepano 5스킬 설치 시 깊이 증가.

## 일관성 카드 5규칙 (스킬이 vault에 자동 박음)

1. **네이밍** — 노트 제목에 검색어 포함
2. **태그** — 시점·주체·주제·문서종류 4축
3. **링크 방향** — 구체 → 추상 (사례가 기준 가리킴)
4. **요약 1줄** — 첫 줄에 "이 노트는 X에 대한 Y이다"
5. **불완전 마커** — `[확인 필요]`, `[질문]`

자세한 풀이는 설치 후 vault의 `_meta/일관성카드.md` 참조.

## 디렉토리 구조

```
won-vault-bootstrap/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   └── bootstrap/
│       ├── SKILL.md
│       ├── templates/        (일관성카드 + 페르소나 4종)
│       ├── prompts/          (1차/2차 빌드)
│       └── scripts/          (PowerShell 헬스체크 + 리프레시)
├── demo/                     (회계사 페르소나용 더미 vault)
├── README.md
└── LICENSE
```

## 검증 통계 (v1.0 릴리즈 시점)

- 옵시디언 CLI 명령 채집: 100+ 개
- E2E 검증 자리: 헬스체크·L1 셋업·L2 reload·핵심 노트 열기·그래프뷰·1차 빌드·백링크 자동 형성·고스트 노트 (모두 통과)
- 강의 정점 50분 → 약 5분으로 압축

## English Summary

**won-vault-bootstrap** is a Claude Code plugin that bootstraps an empty Obsidian vault into an LLM Wiki seed in 5 minutes. Built from Won Seongmuk's lecture IP at Sunmyung Accounting Firm (2026-05-21). Supports 4 personas (Accountant, Lawyer, Journalist, Researcher) with a unified 4-axis properties standard (time, who, topic, kind). Requires Obsidian 1.12.7+ installer (with CLI enabled) and Claude Code. Optional integration with kepano/obsidian-skills for deeper 1st/2nd build operations.

```
/plugin marketplace add simonsez9510/won-vault-bootstrap
/plugin install won-vault-bootstrap@won-vault-bootstrap
```

Then call `/won-vault-bootstrap:bootstrap` in your empty vault. The plugin will ask for your persona once, then auto-create folders, install the consistency card, set up persona properties, run 1st build (raw → wiki notes), and apply the 5-rule consistency card in 2nd build.

## 라이선스

MIT License — 자세한 내용은 [LICENSE](LICENSE) 참조.

## 출처·크레딧

- **개발·집필**: 원성묵 (元 性 黙) · 지방자치혁신연구원 원장 · [won.seongmuk@gmail.com](mailto:won.seongmuk@gmail.com)
- **개념 원전**: Andrej Karpathy의 [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — write-time compilation 패턴
- **5스킬 본가**: Steph Ango([@kepano](https://github.com/kepano))의 [obsidian-skills](https://github.com/kepano/obsidian-skills) — 옵시디언 CEO가 직접 만든 LLM 도구 풀세트
- **강의 모태**: 선명회계법인 AX 실전 아카데미 (2026-05-21)

## 관련 자료

- [원성묵 강의안 (한국어)](https://github.com/simonsez9510/won-vault-bootstrap/blob/main/docs/lecture-handout.md) (추후 추가 예정)
- [지방자치혁신연구원](https://jachinews.kr)

## 변경 이력

- **v1.0.0** (2026-05-24) — PoC E2E 검증 후 첫 공개 릴리즈

---

*"두 번째 뇌, 이번엔 본인 손에. 유지보수를 본인이 안 하는 첫 패턴."*
