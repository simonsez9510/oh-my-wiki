# 1차 빌드 프롬프트

> 이 프롬프트는 빈 vault의 `raw/` 폴더 자료를 *위키 노트 1차 형태*로 자동 변환합니다.
> 일관성 카드는 아직 적용 전 — 노트들의 규칙은 들쭉날쭉할 수 있습니다.
> 그게 정상입니다. 2차 빌드에서 카드 규칙으로 재정렬됩니다.

---

지금 vault의 `raw/` 폴더에 있는 자료를 스캔해서 위키 노트로 1차 변환해줘.

== 사용자 페르소나 ==

페르소나: **{persona}**
- who 라벨: {who_label}
- topic 라벨: {topic_label}
- kind 예시: {kind_examples}
- who 폴더: `{folder_who}/`
- topic 폴더: `{folder_topic}/`

== 작업 절차 ==

1) `raw/` 폴더 안 모든 파일을 스캔.

2) 각 자료마다 *어떤 종류*인지 판단:
   - **사례 자료** (특정 {who_label}·프로젝트·건에 관한 것) → `{folder_who}/` 안에 노트 생성
   - **기준·근거 자료** ({topic_label}에 관한 추상·기준 자료) → `{folder_topic}/` 안에 노트 생성
   - 판단이 모호하면 사례로 분류하고 첫 줄 요약에 `[확인 필요]` 표시

3) 각 노트에 다음 properties 박기 (frontmatter):
   ```yaml
   ---
   time: <자료의 시점, 알 수 없으면 "미상">
   who: <{who_label} 값 또는 "미상">
   topic: <자료가 다루는 핵심 토픽 1~2단어>
   kind: <{kind_examples} 중 가장 적합한 것>
   source: <원본 파일명 — raw/...>
   tags: [<자동 추론한 태그 1~3개>]
   ---
   ```

4) 본문 첫 줄에 1줄 요약: "이 노트는 X에 대한 Y이다."
   - X = 대상 (누구의·무엇에 관한)
   - Y = 문서 종류

5) 본문은 원본 자료의 *핵심 5~10줄*만 발췌. 전문 복사 금지.

6) 가능한 위키링크 추가 — 본 노트가 다른 {topic_label} 노드를 가리킨다면 `[[wikilink]]`.

== 보호 규칙 ==

- `raw/` 폴더 원본은 *절대* 수정 X
- `_meta/일관성카드.md`는 *절대* 수정 X
- 본문 숫자·고유명사 임의 변경 X
- **노트 생성은 파일시스템 직접** (PowerShell / shell write 도구 / LLM 호스트의 Write 등).
  옵시디언 CLI `create name=... path=... content=...` 명령은 한국어 멀티라인
  frontmatter + 본문의 escape(`\n`·따옴표·yaml)가 까다로워 권장 안 함.
  파일시스템 박은 후 vault 인덱싱:
  ```
  obsidian reload
  ```

== 완료 보고 ==

작업 끝나면 다음 한 컷:
- 생성된 노트 개수 (사례 N개 + 기준 M개)
- 폴더별 분포
- `_meta/1차빌드_보고.md` 파일로도 같은 표 박아줘 (파일시스템 직접)
- 마지막에 `obsidian reload` 한 번 호출하고, 1~2초 후 `obsidian open path=_meta/1차빌드_보고.md` (file index sync 지연 시 한 번 더 reload)
- 다음 단계 안내 한 줄: "2차 빌드 진행하시려면 '진행' 입력"
