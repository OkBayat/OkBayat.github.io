## Blueprint عملی برای ساخت سیستم مشابه

ترتیب زیر یک معماری حداقلی مفید است.

### ۱. ابتدا سلسله‌مراتب authority را بنویسید

مشخص کنید reviewer چه چیزی را truth محسوب می‌کند:

```text
base-branch repository policy
  > path-specific policy
  > workflow or skill contract
  > linked specification
  > generic review guideline
```

پیش از نوشتن prompt تصمیم بگیرید contradiction چگونه resolve می‌شود.

### ۲. پوسته‌ی قطعی را از قضاوت مدل جدا کنید

کد قطعی باید مالک این موارد باشد:

- event validation؛
- authentication؛
- queue state؛
- snapshot identity؛
- routing؛
- context cap؛
- schema validation؛
- diff-line validation؛
- duplicate suppression؛
- retry؛
- status؛
- و تمام external writeها.

مدل باید مالک این کارها باشد:

- تفسیر intent؛
- مقایسه‌ی behavior و contract؛
- پیدا‌کردن failure mode مشخص؛
- توضیح evidence؛
- و synthesis findingهای overlapping.

### ۳. Job key و policy کار stale را تعریف کنید

حداقل شکل پیشنهادی:

```text
job_key = repo + pr_number + head_sha
```

مشخص کنید با تغییر head چه اتفاقی برای queued work، running work، status marker و completed work می‌افتد.

### ۴. Review mode را صریح کنید

اگر چهار mode لازم ندارید، با دو mode شروع کنید:

```text
normal
high_risk
```

برای هر mode، passهای لازم، cost limit، failure policy و الزام human review را مشخص کنید.

### ۵. به هر pass فقط یک سؤال بدهید

candidate prompt نامناسب:

```text
Review everything: correctness, architecture, security, tests, style,
performance, product requirements, and repository rules.
```

تفکیک بهتر:

```text
spec:        Did the change satisfy the task?
correctness: Did it introduce a concrete behavior regression?
security:    Did it cross a trust or permission boundary unsafely?
tests:       Is required verification missing or stale?
```

### ۶. Shape سخت‌گیرانه‌ی finding الزام کنید

allowlist کوچکی از check و rule id داشته باشید. این fieldها را الزام کنید:

```text
path
line
side
severity
confidence
title
body
evidence
introduced_by_pr
```

alias و field اضافی را رد کنید. schema پایدار پایه‌ی analytics و learning آینده است.

### ۷. Confidence را یک gate بدانید، نه proof

predicate مفید برای publication بیشتر شبیه این است:

```text
postable =
    schema_valid
    and rule_allowed
    and introduced_by_pr
    and line_in_diff
    and evidence_sufficient
    and not_duplicate
    and not_contradicted
    and confidence >= threshold
    and verifier_passed
    and synthesizer_passed
    and head_is_current
```

هیچ score منفرد مدل نباید بقیه‌ی گیت‌ها را دور بزند.

### ۸. Publication در GitHub را idempotent کنید

در هر inline comment marker مخفی و پایدار قرار دهید. پیش از post، commentهای موجود را بخوانید. برای summary عمومی marker جدا داشته باشید.

### ۹. Metadata ماشین‌خوان را حفظ کنید

commit بازبینی‌شده، route، pass، gate، count، truncation و نتیجه‌ی posting را ثبت کنید. بدون این داده بعداً نمی‌توان clean review را از run ناموفق یا ناقص تشخیص داد.

### ۱۰. رسیدگی به feedback را یک workflow بسازید

به coding agent صرفاً نگویید «همه‌ی commentها را address کن». `fix`، `decline` یا `escalate` را الزام کنید. verification و SHA push‌شده را پیش از resolution بخواهید.

### ۱۱. Outcome reviewer را اندازه‌گیری کنید

metricهای عملیاتی مفید عبارت‌اند از:

- تعداد finding منتشرشده به‌ازای هر Pull Request؛
- نرخ پذیرش comment یا useful reaction؛
- findingهای fix‌شده در برابر declined؛
- false-positive rate به تفکیک rule و mode؛
- stale-head abort؛
- duplicate comment سرکوب‌شده؛
- finding غیرقابل anchor؛
- latency و cost به تفکیک review mode؛
- candidate-agent failure rate؛
- human escalation rate؛
- recurrence پس از fix پذیرفته‌شده؛
- و میزان agreement reviewer خودکار و انسانی.

comment count را optimize نکنید. reviewerای که finding کمتر و بهتر می‌دهد ممکن است ارزشمندتر باشد.

### ۱۲. انسان را در boundaryهای پرریسک نگه دارید

وقتی consequence از evidence در دسترس سیستم بزرگ‌تر است، human review را الزام کنید. در K2، council mode برای تصمیم انسان evidence فراهم می‌کند، نه اینکه جای او را بگیرد.

## راهبرد validation

یک سیستم review در چند لایه به test نیاز دارد.

### Unit testهای قطعی

این موارد را test کنید:

- signatureهای webhook؛
- event و author allowlist؛
- رفتار draft؛
- coalesceکردن delivery تکراری؛
- supersession با head جدید؛
- زمان‌بندی retry؛
- رد schema خروجی؛
- انتخاب route؛
- confidence filtering؛
- parseکردن خط diff؛
- پایداری marker؛
- ساخت review body؛
- مالکیت status؛
- و cleanup پس از interruption.

### Test قرارداد prompt

با fixture بررسی کنید که:

- هر agent فقط fieldهای مجاز را برگرداند؛
- finding کم‌confidence حذف شود؛
- نبود evidence تخصصی fail شود؛
- context مبهم finding تولید نکند؛
- verifier و synthesizer الزام باشند؛
- و failure candidate مطابق policy mode رفتار کند.

### Testهای end-to-end

از test repository یا Pull Request کنترل‌شده استفاده کنید تا این موارد واقعاً سنجیده شوند:

- delivery واقعی webhook؛
- queueing؛
- publication review؛
- inline anchor؛
- رفتار retry؛
- push جدید هنگام اجرای review؛
- duplicate suppression؛
- transition از draft به ready؛
- command دستی؛
- و convergence thread پس از fix یا decline.

### Calibration انسانی

نمونه‌ای از findingها را با این labelها ارزیابی کنید:

```text
correct and important
correct but unimportant
incorrect
duplicate
stale
out of scope
insufficient evidence
```

outcomeها را به تفکیک rule، agent، route، severity و confidence band مقایسه کنید. این مرحله است که در آینده می‌تواند threshold policy فعلی را به decisionی empirically calibrated تبدیل کند.

## محدودیت‌ها و پرسش‌های باز

### Benchmark رسمی منتشر نکرده‌ایم

implementation contract و workflow validation گسترده دارد، اما این مقاله مطالعه‌ی کنترل‌شده‌ای از precision، recall، زمان صرفه‌جویی‌شده‌ی developer یا مقایسه با reviewer تجاری ارائه نمی‌کند.

### Confidence احتمال کالیبره‌شده نیست

threshold برابر ۸۰ یک rule کاربردی برای publication است. پیش از تفسیر آماری باید در برابر outcome انسانی calibrate شود.

### Agentهای یک engine failure mode مرتبط دارند

promptهای تخصصی focus را بهتر می‌کنند، اما استقلال judgment را تضمین نمی‌کنند. evaluation واقعاً multi-model به engineهای خارجی صریح و روشی برای reconcileکردن biasهای متفاوتشان نیاز دارد.

### Policy ثابت می‌تواند stale شود

ruleهای repo و route map باید همراه سیستم evolve شوند. workflow یادگیری می‌تواند update پیشنهاد کند، اما انسان باید بررسی کند outcome محلی تا چه حد generalize می‌شود.

### Context همچنان ناقص است

cap برای cost و safety لازم است. همین cap می‌تواند issue، thread، check یا source file مرتبط را حذف کند. پاسخ درست اغلب suppressکردن finding است، اما suppression recall را پایین می‌آورد.

### GitHub write نسبت به head کاملاً atomic نیست

checkهای قبل و بعد از write race را کاهش می‌دهند، اما نمی‌توانند هر request پذیرفته‌شده توسط GitHub را پس بگیرند. ownership پایدار و cleanup control جبرانی‌اند، نه transaction اتمیک.

### Policy فقط-inline برخی نگرانی‌های معتبر را حذف می‌کند

برخی riskهای معماری یا محصول را نمی‌توان روی یک خط تغییرکرده نمایش داد. K2 عمداً آن‌ها را به inline comment تحمیل نمی‌کند. summary انسانی جدا یا design review همچنان ممکن است لازم باشد.

### Reviewer فقط دانش صریح را خوب enforce می‌کند

تشخیص convention نانوشته از preference شخصی دشوار است. صریح‌کردن authority مخزن هم reviewer را بهتر می‌کند و هم خود سازمان را.

## درس عمیق‌تر

مهم‌ترین تغییر، اضافه‌کردن agentهای بیشتر نبود. واحد طراحی را تغییر دادیم.

دیگر نپرسیدیم:

> چه promptی یک code review خوب تولید می‌کند؟

پرسیدیم:

> چه سیستمی می‌تواند judgment احتمالاتی را با امنیت به تعداد کمی اثر جاری، مستند، actionable و قابل جبران تبدیل کند؟

این سؤال به‌طور طبیعی به این عناصر می‌رسد:

- مرز trusted و untrusted؛
- snapshot صریح؛
- routing قطعی؛
- context محدود؛
- judgment تخصصی؛
- structured output؛
- verification؛
- publication idempotent؛
- mutation جدا؛
- outcome قابل مشاهده؛
- و authority انسانی در boundaryهای پرریسک.

یک LLM reviewer یک model call است.

یک review system قراردادی عملیاتی میان repo، مدل، GitHub، coding agent و انسان‌های مسئول کد است.

K2 LLM Judge زمانی مفید شد که contract را طراحی کردیم، نه فقط prompt را.

## منابع

### معماری ایجنت و workflow

- [Anthropic — Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [OpenAI — A Practical Guide to Building Agents](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/)
- [Yang et al. — SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793)
- [مخزن رسمی SWE-agent](https://github.com/swe-agent/swe-agent)
- [OpenAI — Introducing Structured Outputs in the API](https://openai.com/index/introducing-structured-outputs-in-the-api/)

### LLM-as-a-judge و evaluation

- [OpenAI — Evaluation Best Practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)
- [OpenAI — Working with Evals](https://developers.openai.com/api/docs/guides/evals)
- [OpenAI — Graders](https://developers.openai.com/api/docs/guides/graders)
- [Zheng et al. — Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena](https://arxiv.org/abs/2306.05685)
- [Liu et al. — G-Eval: NLG Evaluation using GPT-4 with Better Human Alignment](https://aclanthology.org/2023.emnlp-main.153/)
- [Chiang and Lee — A Closer Look into Using Large Language Models for Automatic Evaluation](https://aclanthology.org/2023.findings-emnlp.599/)
- [Shi et al. — Judging the Judges: A Systematic Study of Position Bias in LLM-as-a-Judge](https://arxiv.org/abs/2406.07791)
- [Gu et al. — A Survey on LLM-as-a-Judge](https://arxiv.org/abs/2411.15594)
- [مخزن رسمی DeepEval](https://github.com/confident-ai/deepeval)

### زیرساخت بازبینی GitHub

- [GitHub Docs — Validating Webhook Deliveries](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries)
- [GitHub Docs — Handling Webhook Deliveries](https://docs.github.com/en/webhooks/using-webhooks/handling-webhook-deliveries)
- [GitHub Docs — Best Practices for Using Webhooks](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks)
- [GitHub Docs — Webhook Events and Payloads](https://docs.github.com/en/webhooks/webhook-events-and-payloads)
- [GitHub Docs — REST API Endpoints for Pull Request Reviews](https://docs.github.com/en/rest/pulls/reviews)
- [GitHub Docs — Using GitHub Copilot Code Review on GitHub](https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/copilot-code-review)

### ابزارهای بازبینی Pull Request

- [OpenAI — Introducing Upgrades to Codex](https://openai.com/index/introducing-upgrades-to-codex/)
- [مخزن رسمی PR-Agent](https://github.com/The-PR-Agent/pr-agent)
- [CodeRabbit — Pull Request Reviews](https://docs.coderabbit.ai/overview/pull-request-review)
- [CodeRabbit — Automatic Review Controls](https://docs.coderabbit.ai/configuration/auto-review)

## تاریخچه‌ی بازنگری

- **۲۱ ژوئیه‌ی ۲۰۲۶:** نخستین انتشار.
