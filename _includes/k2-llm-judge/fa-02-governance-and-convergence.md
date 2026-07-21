## اجرای multi-agent، بدون تظاهر به اجماع مستقل

K2 یک مسیر native multi-agent پشت feature flag دارد.

وقتی فعال باشد:

1. هر candidate agent انتخاب‌شده در model call جدا و فقط‌خواندنی اجرا می‌شود؛
2. candidate outputها normalize و sanitize می‌شوند؛
3. evidence requirementهای domain بررسی می‌شوند؛
4. failure candidate براساس mode و policy رسیدگی می‌شود؛
5. verifier و synthesizer نهایی candidate findingها را دریافت می‌کنند؛
6. فقط خروجی نهایی versioned schema به publisher می‌رسد.

concurrency candidate به‌صورت پیش‌فرض یک است و حداکثر سه می‌شود. این cap، cost و latency را محدود می‌کند.

failure policy پیش‌فرض fail-closed است. policy اختیاری می‌تواند در modeهای `fast` یا `standard` با candidate ازدست‌رفته ادامه دهد، اما `deep` و `council` همچنان روی failure بسته می‌شوند.

مزیت این معماری تفکیک attention است: security داخل یک candidate prompt با test رقابت نمی‌کند و evidence مربوط به condition audit با style review عمومی مخلوط نمی‌شود.

اما نباید معنای آن را بزرگ‌نمایی کرد. تا زمانی که engine خارجی جداگانه تنظیم نشده، این agentها passهای تخصصی روی یک خانواده‌ی engine مشترک‌اند. خطاهایشان ممکن است correlated باشد. `council_evidence` خودکار multi-model consensus نیست. چند call چند lens می‌سازد، نه independence آماری.

وقتی قابلیت multi-agent غیرفعال است، یک run واحد مدل همچنان باید mode انتخاب‌شده، passهای تکمیل‌شده، نتیجه‌ی verifier و نتیجه‌ی synthesizer را report کند. contract ثابت می‌ماند، حتی اگر strategy اجرا تغییر کند.

## گیت‌های verifier و synthesizer

candidate finding هنوز finding قابل انتشار نیست.

verifier می‌پرسد آیا هر finding پیشنهادی قرارداد publication را برآورده می‌کند:

- آیا خط بخشی از diff تغییرکرده است؟
- آیا issue توسط این Pull Request ایجاد یا actionable شده است؟
- آیا body evidence مشخص را نام می‌برد؟
- آیا نویسنده می‌تواند آن را در همین Pull Request اصلاح کند؟
- آیا authority خاص‌تر آن را نقض نمی‌کند؟
- آیا duplicate نیست؟
- آیا severity impact را نشان می‌دهد، نه uncertainty reviewer را؟
- آیا threshold confidence را پاس می‌کند؟
- آیا finding تخصصی evidence تایپ‌شده‌ی لازم را دارد؟

سپس synthesizer overlap را resolve می‌کند:

- نگرانی‌های تکراری را merge می‌کند؛
- باریک‌ترین rule قابل اعمال را ترجیح می‌دهد؛
- قوی‌ترین نسخه‌ی actionable را نگه می‌دارد؛
- restatementهای عمومی را حذف می‌کند؛
- و نتیجه‌ی نهایی را cap می‌کند.

هر دو gate باید در metadata نهایی موفق گزارش شوند. publisher خروجی‌ای را که فقط ادعای اجرای candidate pass دارد اما verifier و synthesizer موفق ندارد رد می‌کند.

## قرارداد finding

judge خروجی JSON می‌دهد، نه Markdown.

شکل ساده‌شده‌ی finding چنین است:

```json
{
  "schema_version": 2,
  "review_summary": {
    "checks_run": [
      "karpathy_guidelines",
      "condition_audit_judge",
      "professional_pr_review"
    ],
    "inline_findings_count": 1,
    "review_mode": "deep",
    "agent_passes": [
      "spec",
      "standards",
      "correctness",
      "security",
      "performance",
      "tests",
      "review_lifecycle",
      "false_positive_filter",
      "verifier",
      "synthesizer"
    ],
    "verifier_passed": true,
    "synthesizer_passed": true
  },
  "findings": [
    {
      "check_id": "professional_pr_review",
      "rule_id": "correctness_regression",
      "path": "src/example.ts",
      "line": 84,
      "side": "RIGHT",
      "severity": "high",
      "confidence": 91,
      "title": "Preserve the current-head state transition",
      "body": "This branch records completion before the durable write succeeds, so a retry can skip the unfinished operation."
    }
  ]
}
```

سرویس top-level field ناشناخته، check و rule ناشناخته، mode نامعتبر، agent id نامعتبر، gate ناموفق، severity غلط، side نامعتبر، confidence بدشکل و line location نامعتبر را رد می‌کند.

همچنین تعداد raw candidate finding و inline finding نهایی را جداگانه محدود می‌کند. مدل صرفاً با برگرداندن array بزرگ نمی‌تواند Pull Request را flood کند.

### چرا threshold برابر ۸۰ است؟

finding حرفه‌ای باید confidence صحیح بین ۸۰ تا ۱۰۰ داشته باشد. finding زیر ۸۰ حذف می‌شود و نه به‌عنوان issue actionable منتشر می‌شود و نه در summary actionable می‌آید.

این threshold یک policy برای کنترل نویز است. معنایش این **نیست** که «finding با احتمال عینی و کالیبره‌شده‌ی ۸۰ درصد درست است». confidence خودگزارش‌شده‌ی LLM خودکار calibrate نیست. این عدد فقط در کنار evidence، محدودیت rule، anchoring روی خط تغییرکرده، verifier check و feedback انسانی مفید است.

سیستم بالغ باید threshold را با مقایسه‌ی score و outcome انسانی به‌صورت تجربی calibrate کند. تا آن زمان، عدد یک مرز eligibility است، نه ادعای احتمال.

## اتصال finding به خط تغییرکرده

finding باید به خطی اشاره کند که GitHub بتواند آن را داخل diff Pull Request نمایش دهد:

```text
path
line
side = RIGHT | LEFT
```

publisher از patch یک index از خط‌های اضافه و حذف‌شده می‌سازد و هر finding را با آن می‌سنجد.

این کار چند نوع نویز را حذف می‌کند:

- comment گسترده درباره‌ی کد دست‌نخورده؛
- essay معماری که روی یک محل تغییرکرده actionable نیست؛
- comment متصل به context line؛
- و line number ساختگی مدل.

ممکن است یک نگرانی معتبر باشد اما هیچ خط تغییرکرده‌ای نتواند آن را نمایندگی کند. چنین findingهایی skip می‌شوند و ممکن است در summary عمومی گزارش شوند. آن‌ها به زور روی خط نامرتبط قرار نمی‌گیرند.

primitive انتشار، [Pull Request Review API در GitHub](https://docs.github.com/en/rest/pulls/reviews) است. K2 یک review با شکل زیر submit می‌کند:

```json
{
  "commit_id": "<reviewed-head-sha>",
  "event": "COMMENT",
  "body": "<review-summary>",
  "comments": [
    {
      "path": "src/example.ts",
      "line": 84,
      "side": "RIGHT",
      "body": "<finding>"
    }
  ]
}
```

event همیشه `COMMENT` است. سیستم به‌جای human reviewer هیچ‌گاه Pull Request را approve نمی‌کند و `REQUEST_CHANGES` نمی‌فرستد.

## جلوگیری از duplicate و marker پایدار inline

هر inline finding یک marker مخفی دارد:

```html
<!-- k2-llm-as-a-judge:inline:3d7deb43f04b930b -->
```

برای finding عادی، digest از این موارد ساخته می‌شود:

```text
commit SHA
path
line
side
check ID
rule ID
```

برای finding مربوط به condition audit، audit hash پایدار و condition expression می‌توانند جای identity ناپایدار commit و line را بگیرند. بنابراین صرف جابه‌جایی خط‌های اطراف باعث انتشار دوباره‌ی همان نگرانی audit نمی‌شود.

پیش از publication، سرویس review commentهای موجود Pull Request را می‌خواند، markerهای خودش را استخراج می‌کند و duplicate را skip می‌کند.

الگوی عمومی چنین است:

```text
dedupe_key = canonicalize(finding identity)
marker     = sha256(dedupe_key)[0:16]
```

marker signature امنیتی نیست. idempotency keyای است که در محلی پایدار در GitHub قرار می‌گیرد، پس پس از restart process نیز قابل readback است.

## وضعیت review، بدون تظاهر به approval

سرویس از reactionهای Pull Request به‌عنوان state سبک استفاده می‌کند:

- `eyes` هنگام اجرای review؛
- `+1` پس از review clean و موفق که comment actionable ندارد.

اگر finding منتشر شود، reviewer marker clean باقی نمی‌گذارد. اگر head جدید run را supersede کند، مالکیت status نامعتبر می‌شود و cleanup schedule می‌شود.

reactionها به کل Pull Request تعلق دارند، نه به head مشخص. بنابراین queue ثبت می‌کند کدام job و head مالک marker فعلی است. سرویس پیش و پس از mutation مالکیت را بررسی می‌کند و فقط reactionهای خودش را حذف می‌کند.

این مثال کوچکی است از اینکه چرا state خارجی UI به state machine واقعی نیاز دارد. «eyes را اضافه کن و بعد با thumbs-up عوض کن» ساده به نظر می‌رسد تا وقتی دو commit، یک retry و یک process restart هم‌زمان شوند.

## Metadata مخفی review

هر review یا summary یک comment مخفی و ماشین‌خوان شامل fieldهایی مانند این‌ها دارد:

- commit بازبینی‌شده؛
- checkهای اجراشده؛
- review mode؛
- agent passها؛
- وضعیت verifier و synthesizer؛
- تعداد findingها؛
- تعداد commentهای منتشرشده؛
- تعداد skip و duplicate؛
- توزیع severity.

این metadata بدون نیاز به permission ساخت GitHub Check، داده‌ای شبیه check run فراهم می‌کند.

هم‌زمان پایه‌ی evaluation بعدی را می‌سازد. process learning می‌تواند ادعای judge را با resolution thread، reaction، fix، decline و rerun مرتبط کند.

comment قابل خواندن برای انسان، برای developer است. metadata ماشین‌خوان برای integrity lifecycle و measurement است. یک سیستم بالغ به هر دو نیاز دارد.

## فاز دوم: رسیدگی به inline reviewها

انتشار comment پایان کار نیست. workflow مخزن باید آن را ببیند و resolve کند.

K2 این capability را از reviewer جدا نگه می‌دارد.

### وضعیت canonical بازبینی

review loop سمت repo یک snapshot canonical می‌خواند که این موارد را ترکیب می‌کند:

- head فعلی Pull Request؛
- checkهای CI و state آن‌ها؛
- reactionهای `eyes` و `+1` reviewer؛
- review decision؛
- inline threadهای unresolved؛
- comment id و anchor؛
- timestamp و cutoff متصل به آخرین push؛
- markerهای feedback نامعتبر که قبلاً handled شده‌اند.

سیستم از یک REST call یا نبود notification جدید نتیجه نمی‌گیرد که PR clean است. تا برآورده‌شدن conditionهای reviewer و CI تنظیم‌شده صبر می‌کند.

### هر مورد به fix، decline یا escalate تبدیل می‌شود

workflow دارای write capability هر مورد unresolved را دقیقاً به یکی از این سه حالت طبقه‌بندی می‌کند:

| Classification | معنا | اقدام |
|---|---|---|
| `fix` | از نظر factual درست، داخل scope، actionable و امن روی branch فعلی | کوچک‌ترین تغییر را بده، verify کن، commit و push کن، با evidence پاسخ بده و سپس resolve کن |
| `decline` | نامعتبر، stale، duplicate، متناقض با authority قوی‌تر یا خارج scope | کد را تغییر نده؛ دلیل فنی کوتاه بده و handled علامت بزن |
| `escalate` | مبهم، ناامن، متعارض یا وابسته به تصمیم maintainer | automation را متوقف و decision را روشن ارائه کن |

خود comment درخواستی برای ارزیابی است، نه دستوری برای اطاعت.

پیش از پذیرش، fixer می‌پرسد:

- آیا در branch فعلی واقعاً درست است؟
- آیا برای contract اعلام‌شده‌ی Pull Request لازم است؟
- آیا داخل scope است؟
- آیا feature جدیدی وارد نمی‌کند؟
- آیا failure mode عملی را حل می‌کند؟
- آیا با diff کوچک و local قابل اصلاح است؟
- آیا نتیجه قابل verification است؟

اگر پاسخ هرکدام منفی باشد، سیستم فقط برای راضی‌کردن reviewer کد را تغییر نمی‌دهد.

### Fix باید پیش از resolveشدن thread push شود

برای feedback معتبر، ترتیب چنین است:

```text
inspect
  → patch
  → focused verification
  → commit
  → push
  → reply with SHA and evidence
  → resolve thread
  → wait for current-head review and CI again
```

این ترتیب ارتباط قابل audit میان review comment، fix دقیق و validation پس از fix را حفظ می‌کند.

پس از هر push، loop روی head جدید و cutoff تازه آغاز می‌شود. تا clean، timeout یا blocker خارجی مشخص ادامه می‌دهد.

### Feedback نامعتبر نیز باید به convergence برسد

نادیده‌گرفتن comment بد آن را برای همیشه pending می‌گذارد. resolveکردن بدون توضیح نیز disagreement را پنهان می‌کند.

K2 زیر feedback نامعتبر یا خارج scope یک دلیل کوتاه پاسخ می‌دهد و marker مخفی handled قرار می‌دهد. marker مانع می‌شود همان comment قبلاً رسیدگی‌شده scan بعدی را block کند، در حالی که توضیح visible تصمیم فنی را حفظ می‌کند.

این یکی از مهم‌ترین درس‌های عملیاتی است: false-positive handling بخشی از محصول است، نه استثنایی بیرون workflow.

## مسئولیت سوم و جداگانه: یادگیری از outcomeها

K2 review learning را نیز از review و fixing جدا می‌کند.

workflow یادگیری می‌تواند این موارد را بررسی کند:

- metadata مخفی review؛
- reaction مفید یا غیرمفید؛
- resolution thread؛
- fix commit؛
- دلیل decline و escalation؛
- verification evidence؛
- تکرار finding مشابه؛
- و policy فعلی routing یا severity.

این workflow می‌تواند تغییر کوچک و evidence-backed در policy را از طریق branch و Pull Request عادی پیشنهاد کند. کد product، policy reviewer یا memory پایدار را مستقیماً درجا بازنویسی نمی‌کند.

جداسازی عمدی است:

```text
reviewer  → proposes findings
fixer     → handles current findings
learner   → proposes changes to future review policy
```

ترکیب این نقش‌ها یک سیستم self-modifying می‌سازد که ممکن است پس از یک review ناخوشایند استاندارد خودش را پایین بیاورد یا بدون تأیید انسان authority خود را گسترش دهد.

## چه چیز در طراحی K2 متمایز است؟

بسیاری از ابزارهای مدرن review، بازبینی خودکار، context مخزن، inline comment، command یا fix را پشتیبانی می‌کنند. contribution K2 وجود تک‌تک این featureها نیست؛ ترکیب صریح boundaryهای governance پیرامون آن‌هاست.

### Policy بازبینی در trusted base مخزن زندگی می‌کند

risk routing، rule idها، evidence requirementهای specialist و تعریف review modeها همراه codebase version می‌شوند و مانند کد review می‌شوند.

### Publisher قطعی و دارای credential است؛ judge احتمالاتی و بدون credential

مدل finding تایپ‌شده پیشنهاد می‌دهد. سرویس Node تصمیم می‌گیرد آیا آن finding می‌تواند به GitHub write تبدیل شود یا نه.

### Review، mutation و learning capabilityهای جدا هستند

judge از نوع comment-only نمی‌تواند پنهانی branch را بازنویسی کند. fixer نمی‌تواند policy بازبینی را دوباره تعریف کند. learner نمی‌تواند proposal خودش را اعمال کند.

### مالکیت head فعلی invariant درجه‌اول است

job، status reaction، model output، comment، cleanup و retry همگی به SHA بازبینی‌شده متصل‌اند.

### Low-noise بودن encode شده، نه فقط درخواست شده است

confidence threshold، changed-line anchoring، rule پایدار، evidence تایپ‌شده، verifier و synthesizer، cap finding و duplicate marker همگی policy نویز را enforce می‌کنند.

### Domain review route می‌شود، نه اینکه به یک prompt عظیم چسبانده شود

capital risk، order execution، condition audit و backtest evidence pass و evidence type جدا دارند.

### Run پاک اجازه دارد ساکت باشد

سیستم برای اثبات اینکه اجرا شده، summary ساختگی تولید نمی‌کند. وقتی چیزی actionable وجود ندارد، یک reaction سبک کافی است.

## مقایسه با رویکردهای موجود

مقایسه‌ی زیر product surface عمومی و تأکید طراحی را توضیح می‌دهد، نه implementation مخفی ابزارها را.

| رویکرد | قوتی که به‌صورت عمومی مستند شده | تأکید طراحی K2 |
|---|---|---|
| OpenAI Codex review | بازبینی intent نسبت به diff، navigation مخزن، اجرای کد و test و follow-up در GitHub | داوری فقط‌خواندنی روی trusted base، routing مختص repo، publisher قطعی و fixer جدا |
| GitHub Copilot code review | reviewer بومی GitHub، خروجی comment-only، instructionهای base branch و path و suggestionهای قابل اعمال | گیت schema و confidence صریح، evidence تخصصی، مالکیت job و reaction مبتنی بر SHA |
| PR-Agent | متن‌باز و self-hostable، command و model قابل تنظیم، چند Git provider | policy عمیق مختص K2 و convergence دو‌فازی review/fix |
| CodeRabbit | بازبینی خودکار و incremental، context issue و repo، feedback تیم و conversation | authority versioned در repo، contract صریح verifier/synthesizer و metadata ماشین‌خوان lifecycle |
| SWE-agent | agent-computer interface برای navigation، editing و testing repo | استفاده از درس ACI همراه جداسازی review فقط‌خواندنی از remediation دارای write |
| یک prompt ساده‌ی LLM | پیچیدگی کم و هزینه‌ی راه‌اندازی پایین | افزودن پیچیدگی فقط جایی که reliability عملیاتی آن را توجیه می‌کند |

انتخاب درست به سازمان بستگی دارد. reviewer عمومی hosted ممکن است برای بسیاری از تیم‌ها بهترین پاسخ باشد. یک repo کوچک ممکن است فقط به یک prompt خوب و human reviewer نیاز داشته باشد. معماری K2 به‌دلیل contractهای خاص مخزن، domainهای quantitative پرریسک، workflowهای خودکار agent و نیاز به inspectableبودن رفتار review توجیه پیدا می‌کند.

## Failure modeهایی که دیدیم یا سیستم را برای مقاومت در برابرشان ساختیم

### نویز عمومی review

prompt گسترده‌ی «این PR را review کن» معمولاً naming advice، hardening حدسی و پیشنهاد refactor آینده می‌دهد. K2 ruleها را محدود می‌کند، evidence و line anchor می‌خواهد و صریحاً finding ندادن را ترجیح می‌دهد.

### انتشار برای head قدیمی

model call طولانی ممکن است بعد از push commit تازه تمام شود. queue کار قدیمی را cancel و پیش از publication head را دوباره check می‌کند.

### Prompt injection در Pull Request

کد و prose غیرقابل‌اعتماد ممکن است به agent بگوید ruleها را نادیده بگیرد یا credential افشا کند. K2 trusted base را checkout می‌کند، محتوای PR را evidence می‌داند، read-only اجرا می‌شود و tokenها را بیرون process مدل نگه می‌دارد.

### Comment تکراری پس از retry

retry ممکن است همان finding را دوباره بسازد. marker مخفی و قطعی publication را در attemptهای مختلف idempotent می‌کند.

### اجماع کاذب از چند agent

چند call به یک خانواده‌ی مدل ممکن است یک misconception مشترک را تکرار کنند. K2 از specialization و synthesis استفاده می‌کند اما آن را consensus مستقل نمی‌نامد؛ council mode پرریسک همچنان human review می‌خواهد.

### JSON درست با معنای غلط

schema conformance می‌تواند output ضعیف از نظر معنا را پنهان کند. سرویس پس از parse، rule، line، confidence، evidence، pass metadata و state فعلی را اعتبارسنجی می‌کند.

### Finding قابل قبول اما غیرقابل anchor

نگرانی درباره‌ی کل سیستم ممکن است به یک خط تغییرکرده وصل نشود. به‌جای اتصال گمراه‌کننده، skip یا summarize می‌شود.

### تبدیل reviewer به fixer

اگر judge یافته‌های خودش را اعمال کند، detection، authorization و mutation به یک عمل opaque تبدیل می‌شوند. K2 حلقه‌ی دارای write برای convergence را جدا می‌کند.

### Loop بی‌پایان بازبینی

fix یک head جدید می‌سازد که می‌تواند review دیگری ایجاد کند. loop outcomeهای صریح clean، timeout، retry و blocker دارد و بی‌نهایت اجرا نمی‌شود.

### انفجار cost و latency

agentهای موازی تعداد call را ضرب می‌کنند. routing، feature flag، concurrency cap، finding cap و failure policy وابسته به mode، سیستم را bounded نگه می‌دارند.
