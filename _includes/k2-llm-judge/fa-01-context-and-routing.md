## مسئله، تولید comment نیست

ساده‌ترین شکل بازبینی کد با هوش مصنوعی شبیه این است:

```text
diff + prompt
     |
     v
    LLM
     |
     v
review text
```

این مسیر می‌تواند مشاهده‌های خوبی تولید کند. در عین حال ممکن است preferenceهای سلیقه‌ای، defectهای خیالی، commentهای تکراری، توصیه درباره‌ی کدی که اصلاً تغییر نکرده، finding مبتنی بر commit قدیمی یا ادعایی مطمئن ولی ناسازگار با قرارداد خاص مخزن تولید کند.

بنابراین مسئله‌ی اصلی در production این نیست که «آیا LLM چیزی برای گفتن پیدا می‌کند؟» مسئله این است که آیا سیستم پیرامونی می‌تواند تصمیم بگیرد:

1. آیا comment واقعاً پشتوانه دارد؟
2. آیا آن‌قدر مهم هست که توجه تیم را مصرف کند؟
3. آیا به یک خط تغییرکرده تعلق دارد؟
4. آیا قبلاً گفته شده است؟
5. آیا هنوز برای head فعلی معتبر است؟
6. آیا انتشار آن امن است؟
7. و پس از انتشار چه باید رخ دهد؟

این تفاوت مهم است، چون review comment رفتار تیم را تغییر می‌دهد. توجه مصرف می‌کند، ممکن است merge را عقب بیندازد، تغییر غیرضروری ایجاد کند و صرفاً به‌دلیل لحن مطمئن، authoritative تلقی شود. یک بازبین پرنویز فقط کمکی نمی‌کند؛ ممکن است فرایند مهندسی را بدتر کند.

به همین دلیل کیفیت بازبینی را نه یک مسئله‌ی prompt، بلکه یک مسئله‌ی طراحی سیستم در نظر گرفتیم.

## منظور ما از LLM-as-a-judge چیست؟

در ادبیات پژوهشی، LLM-as-a-judge معمولاً خروجی یک مدل دیگر را در برابر معیارها، پاسخ مرجع یا preference انسانی ارزیابی می‌کند. کارهایی مانند [MT-Bench و Chatbot Arena](https://arxiv.org/abs/2306.05685)، [G-Eval](https://aclanthology.org/2023.emnlp-main.153/) و surveyهای بعدی مانند [A Survey on LLM-as-a-Judge](https://arxiv.org/abs/2411.15594) نشان می‌دهند چرا این الگو جذاب است: می‌توان معیارهای زبان طبیعی را در مقیاس بالا روی خروجی‌هایی اعمال کرد که سنجش آن‌ها با metricهای ساده‌ی قطعی دشوار است.

همین منابع نشان می‌دهند که استفاده‌ی ساده‌انگارانه از این الگو خطرناک است. داورهای مبتنی بر LLM می‌توانند position bias، verbosity bias، self-preference، ناپایداری و ضعف در تمایز گزینه‌های نزدیک داشته باشند. مقاله‌ی [Judging the Judges](https://arxiv.org/abs/2406.07791) position bias را به‌طور نظام‌مند بررسی می‌کند و [A Closer Look into Using Large Language Models for Automatic Evaluation](https://aclanthology.org/2023.findings-emnlp.599/) نشان می‌دهد حتی جزئیاتی مانند درخواست توضیح می‌تواند هم‌راستایی با rating انسانی را به‌طور معنادار تغییر دهد.

K2 از همان الگوی کلی استفاده می‌کند، اما شیء مورد ارزیابی را تغییر می‌دهد. judge پاسخ یک chatbot دیگر را نمره نمی‌دهد؛ یک Pull Request را در برابر چند طبقه از شواهد می‌سنجد:

- task یا specification بیان‌شده؛
- قراردادهای مخزن و workflow؛
- خط‌های تغییرکرده و رفتار source اطراف آن‌ها؛
- شواهد test و CI؛
- invariantهای lifecycle بازبینی؛
- و برای surfaceهای تخصصی K2، شواهد strategy، condition audit، capital risk، order execution و backtest.

خروجی یک score آزاد نیست. خروجی یک finding تایپ‌شده است که پیش از تبدیل‌شدن به GitHub comment باید از چند گیت عبور کند.

## چه کارهایی را بررسی کردیم و از هرکدام چه آموختیم؟

طراحی را از صفحه‌ی سفید شروع نکردیم. راهنماهای معماری ایجنت، پژوهش‌های evaluation، محصولات بازبینی GitHub، agentهای متن‌باز Pull Request و ایجنت‌های مهندسی نرم‌افزار را بررسی کردیم. هدف کپی‌کردن یک سیستم نبود؛ هدف پیدا‌کردن الگوهایی بود که بتوان آن‌ها را درون محدودیت‌های اعتماد و workflow خاص K2 ترکیب کرد.

### معماری ایجنت

[Building Effective Agents از Anthropic](https://www.anthropic.com/engineering/building-effective-agents) میان workflowهای ازپیش‌تعریف‌شده و agentهایی که مسیر خود را پویا هدایت می‌کنند تمایز می‌گذارد و الگوهایی مانند routing، parallelization، orchestrator-worker و evaluator-optimizer را توضیح می‌دهد. سه ایده برای ما اهمیت ویژه داشت:

- نگرانی‌های متفاوت را به promptهای تخصصی route کنیم، نه اینکه یک prompt همه‌چیز را پوشش دهد؛
- وقتی زاویه‌های مستقل توجه یا اطمینان را بهتر می‌کنند، callهای موازی داشته باشیم؛
- اطراف خروجی‌های میانی و نهایی، گیت‌های programmatic قرار دهیم.

[راهنمای عملی OpenAI برای ساخت agent](https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/) نیز بر ابزارها و دستورهای روشن، افزایش تدریجی پیچیدگی، guardrail، exit condition صریح و مداخله‌ی انسان در اقدام‌های پرریسک تأکید می‌کند.

K2 الگوهای ترکیبی را پذیرفت، اما routing و publication را بیرون مدل نگه داشت. مدل تعیین نمی‌کند کدام رویداد GitHub معتبر است، job stale شده یا نه، یک خط در diff هست یا نه، یا اجازه دارد چیزی در GitHub بنویسد.

### مهندسی ارزیابی

راهنماهای OpenAI شامل [Evaluation Best Practices](https://developers.openai.com/api/docs/guides/evaluation-best-practices)، [Working with Evals](https://developers.openai.com/api/docs/guides/evals) و [Graders](https://developers.openai.com/api/docs/guides/graders) چند اصل را تقویت کردند:

- پیش از optimizeکردن سیستم، معیارها را تعریف کنیم؛
- تا جای ممکن تصمیم‌های concrete از جنس pass/fail یا pairwise را ترجیح دهیم؛
- داوری خودکار را در برابر قضاوت انسانی calibrate کنیم؛
- context کافی برای بازرسی failureها ثبت کنیم؛
- و evaluation را یک فرایند مهندسی پیوسته بدانیم، نه یک prompt یک‌باره.

[DeepEval](https://github.com/confident-ai/deepeval) نیز نمونه‌ی مفیدی بود از اینکه چگونه می‌توان evaluation مبتنی بر LLM را به metricهای تکرارپذیر و شبیه test با threshold، explanation، dataset و CI integration تبدیل کرد.

قواعد بازبینی K2، threshold اطمینان، خروجی تایپ‌شده، verifier pass، metadata مخفی و workflow جداگانه‌ی learning همگی از این نگاه eval-driven اثر گرفته‌اند.

### خروجی ساختاریافته

[Structured Outputs در OpenAI](https://openai.com/index/introducing-structured-outputs-in-the-api/) ارزش محدودکردن خروجی مدل به schema را نشان می‌دهد. در عین حال یک محدودیت مهم را هم روشن می‌کند: مطابقت با schema تضمین نمی‌کند مقدارهای داخل آن درست باشند.

مرز K2 دقیقاً همین است. JSON معتبر فقط گیت اول است. سرویس جداگانه rule idها، anchoring خط، confidence، evidence requirement، duplicate marker، metadata حالت بازبینی و مالکیت head فعلی را اعتبارسنجی می‌کند.

### محصولات بازبینی هوش مصنوعی و ابزارهای متن‌باز

چند سیستم به روشن‌شدن product surface مورد انتظار کمک کردند:

- [بازبینی کد OpenAI Codex](https://openai.com/index/introducing-upgrades-to-codex/) intent در Pull Request، context مخزن، اجرای کد، test، بازبینی خودکار و follow-up روی thread را به هم متصل می‌کند.
- [GitHub Copilot code review](https://docs.github.com/en/copilot/how-tos/copilot-on-github/use-copilot-agents/copilot-code-review) اهمیت reviewهای comment-only، suggestionهای آماده‌ی اعمال، دستورهای base branch و راهنمای بازبینی مختص repo یا path را نشان می‌دهد.
- [PR-Agent](https://github.com/The-PR-Agent/pr-agent) یک workflow متن‌باز و self-hostable برای Pull Request ارائه می‌کند که commandهایی مانند review، describe، improve و ask، promptهای configurable و پشتیبانی از چند Git provider دارد.
- مستندات [CodeRabbit برای Pull Request review](https://docs.coderabbit.ai/overview/pull-request-review) درباره‌ی بازبینی خودکار و incremental، issue context، دانش مخزن، feedback و follow-up مکالمه‌ای توضیح می‌دهد.

ادعا نمی‌کنیم K2 به‌صورت عمومی از این سیستم‌ها بهتر است. آن‌ها مسائل محصولی گسترده‌تری حل می‌کنند و درباره‌ی implementation داخلی خود اطلاعات متفاوتی دارند. طراحی ما محدودتر است: یک سیستم governance برای بازبینی مختص مخزن که policyها، routeهای ریسک، evidence requirement، publication gate و fix workflow آن در K2 صریح و قابل آزمون‌اند.

### ایجنت‌های مهندسی نرم‌افزار

[مقاله‌ی SWE-agent](https://arxiv.org/abs/2405.15793) و [مخزن رسمی آن](https://github.com/swe-agent/swe-agent) مفهوم agent-computer interface را مطرح می‌کنند: ابزار و feedback باید با توانایی‌ها و محدودیت‌های مدل زبانی طراحی شوند.

این درس در سراسر K2 دیده می‌شود. judge context محدود و تایپ‌شده می‌گیرد. candidate passها finding با shape محدود برمی‌گردانند. publisher مالک GitHub writeهاست. fixer وضعیت canonical thread را دریافت می‌کند، نه اینکه آن را از چند command پراکنده حدس بزند. به‌جای دسترسی دلخواه به محیط، interfaceای به مدل داده می‌شود که بتواند به‌طور قابل اتکا با آن کار کند.

## هدف‌های طراحی و چیزهایی که هدف نبودند

سیستم حول شش هدف ساخته شد.

### سیگنال بالا به‌جای حجم بالا

یک review پاک ممکن است هیچ commentی نداشته باشد. سکوت خروجی معتبر است. سیستم باید از دست‌دادن یک مشاهده‌ی ضعیف را به انتشار finding حدسی ترجیح دهد.

### شواهد پیش از authority

finding باید رفتار، قرارداد یا شاهد مخزن را نام ببرد که نشان می‌دهد خط تغییرکرده چرا غلط است. لحن مطمئن، evidence نیست.

### صحت نسبت به head فعلی

هر review به head SHA دقیق متصل است. نتیجه‌ی مربوط به commit قدیمی نباید روی وضعیت جدید Pull Request منتشر شود.

### قضاوت مختص مخزن

توصیه‌ی عمومی نرم‌افزاری زیرمجموعه‌ی authorityهای خاص K2 است. خطی که جداگانه عجیب به نظر می‌رسد ممکن است توسط workflow استراتژی، agent skill، operating rule یا validation contract لازم شده باشد.

### داوری فقط‌خواندنی و mutation جداگانه

بازبین نباید پنهانی کد را edit کند، thread را resolve کند یا Pull Request را approve کند. اصلاح‌کردن capability دیگری با مرز ریسک متفاوت است.

### lifecycle ماشین‌خوان

سیستم باید state ساختاریافته‌ی کافی ارائه دهد تا بتوان فهمید چه چیزی بازبینی شده، کدام passها اجرا شده‌اند، چه چیزی منتشر یا skip شده و feedback بعدی چگونه رسیدگی شده است.

چیزهایی که هدف نبودند نیز به همان اندازه مهم‌اند:

- جایگزین human review نیست.
- style linter نیست.
- مولد عمومی توصیه‌ی معماری نیست.
- formal proof system نیست.
- در مسیر judge کد غیرقابل‌اعتماد Pull Request را اجرا نمی‌کند.
- فیلد `confidence` احتمال کالیبره‌شده نیست.
- «multi-agent» به‌طور خودکار به معنای مدل‌های مستقل یا failure modeهای مستقل نیست.

## معماری در یک نگاه

```text
GitHub webhook or poller
          |
          v
Signature, event, author, draft, and repository gates
          |
          v
SHA-aware durable queue
  - coalesce duplicate deliveries
  - cancel superseded work
  - retry bounded failures
          |
          v
Isolated trusted-base worktree
          |
          v
Bounded PR context assembly
  - diff and changed files
  - linked task/specification
  - review threads and prior comments
  - CI/check summaries
  - repository authorities
          |
          v
Deterministic risk router
  fast | standard | deep | council
          |
          v
Specialized candidate passes
  spec | standards | correctness | security | performance
  tests | lifecycle | false-positive filter
  strategy | condition audit | capital risk | order execution | backtest
          |
          v
Verifier + synthesizer
          |
          v
Schema, confidence, evidence, line, duplicate, and current-head gates
          |
          v
GitHub COMMENT review with inline findings
          |
          v
Repository-side convergence loop
  fix | decline | escalate
          |
          v
Optional evidence-backed review learning
```

بهترین مدل ذهنی، یک پوسته‌ی قطعی پیرامون هسته‌ای احتمالاتی و محدود است. این الگو استدلال مرکزی مقاله‌ی مرتبط من نیز هست: [طراحی اسکیل‌های بزرگ ایجنت به‌صورت سیستم‌های قطعی و فازمحور](/thinking/essays/phase-oriented-agent-skills-fa).

## فاز اول: دریافت کار از GitHub

### Webhook و polling دو ورودی برای یک صف‌اند

سرویس می‌تواند webhookهای `pull_request` از GitHub را دریافت کند و هم‌زمان Pull Requestهای باز اخیر را poll کند. هر دو مسیر دقیقاً یک شکل داخلی از job می‌سازند.

Webhook مفید است چون تقریباً فوری عمل می‌کند. Polling مفید است چون وابستگی به یک مسیر ورودی عمومی را کم می‌کند و هنگام failure زیرساخت delivery می‌تواند کار ازدست‌رفته را بازیابی کند. این‌ها دو implementation جدا برای review نیستند؛ دو مکانیزم مشاهده‌اند که یک state machine مشترک را تغذیه می‌کنند.

برای webhook، سرویس مدل امنیتی GitHub را رعایت می‌کند:

- پیش از parse و queueکردن، HMAC موجود در `X-Hub-Signature-256` را اعتبارسنجی می‌کند؛
- webhook secret را در storage امن نگه می‌دارد؛
- signature را با عملیات constant-time مقایسه می‌کند؛
- repo و event نامرتبط را رد می‌کند؛
- و delivery را سریع acknowledge می‌کند، در حالی که پردازش اصلی asynchronous ادامه می‌یابد.

این روش با مستندات GitHub درباره‌ی [اعتبارسنجی webhook delivery](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries)، [رسیدگی به delivery](https://docs.github.com/en/webhooks/using-webhooks/handling-webhook-deliveries) و [بهترین رویه‌های webhook](https://docs.github.com/en/webhooks/using-webhooks/best-practices-for-using-webhooks) هم‌راستاست.

### Allowlist رویداد عمداً محدود است

بازبینی خودکار فقط transitionهای مرتبط Pull Request را می‌پذیرد، مانند:

```text
opened
reopened
ready_for_review
synchronize
```

تبدیل به draft، state محلی recovery را به‌روز می‌کند اما خودکار review را آغاز نمی‌کند. Pull Requestهای draft تا زمانی که GitHub آن‌ها را ready اعلام کند skip می‌شوند.

trigger دستی با commandهای دقیق top-level پشتیبانی می‌شود:

```text
/k2 review
/k2 review once
/k2 review deep
```

این commandها فقط از owner، member یا collaborator پذیرفته می‌شوند. parser تنها خط اول allowlist‌شده را می‌خواند و هیچ‌گاه متن comment را اجرا نمی‌کند.

این مرز کوچک اما مهمی در برابر prompt injection است. comment نه shell command است و نه دستور به reviewer. یا یک control token شناخته‌شده است یا evidence غیرقابل‌اعتماد.

### هر job به یک head SHA متصل است

هویت پایدار کار بازبینی در عمل چنین است:

```text
repository + pull_request_number + head_sha
```

این هویت چند رفتار قطعی را ممکن می‌کند:

- deliveryهای تکراری webhook برای یک head با هم coalesce می‌شوند؛
- polling و webhook دو job خودکار تکراری نمی‌سازند؛
- head جدید، jobهای queued برای headهای قدیمی را حذف می‌کند؛
- head جدید review در حال اجرا برای head قدیمی را abort می‌کند؛
- پیش از اجرای مدل، head زنده‌ی Pull Request دوباره بررسی می‌شود؛
- و پیش از publication نیز دوباره بررسی می‌شود.

GitHub transaction اتمیکی از جنس «این review را فقط وقتی منتشر کن که head هنوز X است» ارائه نمی‌دهد. push ممکن است با writeای که API قبلاً پذیرفته race کند. K2 پنجره‌ی race را کوچک می‌کند، cancellation را به درخواست‌های GitHub منتقل می‌کند، قبل و بعد از mutationهای مهم وضعیت را می‌سنجد و هرجا mutation stale ممکن است رخ داده باشد cleanup پایدار ثبت می‌کند.

درس کلی‌تر از این implementation است:

> اجازه ندهید reviewer هوش مصنوعی درباره‌ی «Pull Request» به‌عنوان یک شیء انتزاعی و متحرک استدلال کند. هر run، output، status marker و write را به snapshot صریح متصل کنید.

### Retry محدود و stateful است

failureهای گذرا با تعداد attempt و delay محدود retry می‌شوند. failure نهایی status markerهای متعلق به reviewer را پاک می‌کند. cleanup به‌عنوان کار پایدار ثبت می‌شود، نه یک `finally` خوش‌بینانه که با خروج process از بین برود.

این موضوع مهم است چون reaction و comment، state قابل مشاهده‌ی خارجی‌اند. crash پس از افزودن علامت «review in progress» نباید Pull Request را برای همیشه در حالت فعال باقی بگذارد.

## مرز اعتماد: Pull Request شاهد است، نه دستور

Pull Request ممکن است از branch یا contributor غیرقابل‌اعتماد بیاید. عنوان، body، کد تغییرکرده، commentها، issueهای لینک‌شده، نام branch و artifactهای test آن می‌توانند متن‌هایی داشته باشند که شبیه دستور به ایجنت‌اند.

judge بنابراین از مدل trusted-base استفاده می‌کند:

1. یک worktree تازه و ایزوله می‌سازد؛
2. commit قابل‌اعتماد base را checkout می‌کند؛
3. head Pull Request را checkout یا execute نمی‌کند؛
4. patch مربوط به head را data در نظر می‌گیرد؛
5. مدل را در sandbox فقط‌خواندنی و ephemeral اجرا می‌کند؛
6. credentialهای GitHub را در process publisher نگه می‌دارد؛
7. و آن credentialها را به process مدل نمی‌دهد.

دستورهای repo، policyها، skillها و routeهای review از base branch خوانده می‌شوند. این منطق با دلیل استفاده‌ی GitHub Copilot از custom instructionهای base branch هم‌راستاست: کدی که زیر review است نباید بتواند authority reviewer را بازنویسی کند.

این جداسازی از نوشتن جمله‌ی «prompt injection را نادیده بگیر» داخل prompt قوی‌تر است. capability را از process مدل حذف می‌کند و برای متن غیرقابل‌اعتماد هیچ مسیر مستقیمی به write دارای credential یا اجرای کد باقی نمی‌گذارد.

## ساختن context بازبینی

reviewerای که فقط diff را می‌بیند، intent و معنای محلی repo را ندارد. reviewerای که کل repo، تمام issueها، commentها و logها را می‌بیند، گران، کند و دشوار برای reasoning می‌شود.

K2 context محدود با capهای صریح و signalهای truncation می‌سازد.

این context می‌تواند شامل موارد زیر باشد:

- عنوان، body، labelها، نویسنده، base و head Pull Request؛
- issueهای لینک‌شده و acceptance evidence؛
- فایل‌های تغییرکرده، patchها و اندازه‌ی diff؛
- review commentهای قبلی؛
- وضعیت GraphQL review thread، شامل discussionهای resolved و unresolved؛
- خلاصه‌ی CI و checkهای فعلی؛
- fetch error و flagهای truncation؛
- instructionهای مرتبط repo و skill contractها؛
- دانش عملیاتی پروژه که surface تغییرکرده لازم دارد؛
- و evidence تخصصی مانند condition-audit data اعتبارسنجی‌شده.

قاعده‌ی مهم «اطلاعات بیشتری بگیر» نیست. قاعده این است:

> کمترین context معتبر لازم برای اثبات یا رد یک candidate finding را دریافت کنید و نبودن یا truncatedبودن context را آشکار نگه دارید.

اگر context لازم در دسترس یا بدون ابهام نباشد، policy بازبینی حرفه‌ای finding ندادن را ترجیح می‌دهد. نبود evidence به‌طور پنهانی به evidence failure تبدیل نمی‌شود.

## پیش از قضاوت، authority باید resolve شود

K2 یک سلسله‌مراتب authority دارد.

یک guideline عمومی ممکن است سادگی یا تغییر surgical را توصیه کند. یک workflow خاص‌تر ممکن است همان فایل، metadata block، validation sequence یا ساختار ظاهراً عجیب را الزام کند. authority خاص‌تر برنده است.

پیش از emitکردن finding، reviewer ممکن است این زنجیره را resolve کند:

```text
repository AGENTS.md
      ↓
review policy and path routing
      ↓
relevant skill contract
      ↓
required skill references
      ↓
project operating knowledge
      ↓
nearby trusted-base source behavior
```

متن Pull Request برای پیدا‌کردن authorityهای مرتبط کمک می‌کند، اما خودش authority نمی‌شود.

این کار یک failure mode رایج در AI review عمومی را کم می‌کند: مدل design ناآشنا را فقط به‌دلیل نداشتن قرارداد محلی توضیح‌دهنده‌ی آن، غلط تشخیص می‌دهد.

## Risk routing: هر Pull Request به یک نوع review نیاز ندارد

اصلاح مستندات نباید همان latency و cost تغییر در order execution را بدهد. تغییر معمول application نباید با rubric تغییر در خود reviewer بررسی شود.

router موجود در trusted base یکی از چهار mode را انتخاب می‌کند.

| Mode | Surface معمول | Passهای لازم |
|---|---|---|
| `fast` | مستندات، fixture، lockfile یا test کم‌ریسک | standards، tests/evidence، verifier، synthesizer |
| `standard` | تغییر معمول کد | specification، standards، correctness، tests/evidence، verifier، synthesizer |
| `deep` | CI، webhook، GitHub write، migration، کد reviewer یا automation بزرگ و پرریسک | specification، standards، correctness، security، performance، tests/evidence، review lifecycle، false-positive filter، verifier، synthesizer |
| `council` | strategy، capital، risk، order، exchange execution، authentication، secret یا permission بحرانی | domain passهای انتخاب‌شده، verifier، synthesizer، council evidence و human review |

routing قطعی است و از policy fileهای JSON موجود در trusted base خوانده می‌شود. path rule و label می‌توانند mode را بالا ببرند. فایل حساس policy فقط چون پسوند `.md` دارد به mode سریع نمی‌رود.

این کاربردی از routing pattern مطرح‌شده توسط Anthropic است، اما classifier عمدتاً conventional code و policy repo است، نه تصمیم آزاد مدل.

## Passهای تخصصی بازبینی

professional review به passهای متمرکز تقسیم می‌شود.

passهای عمومی عبارت‌اند از:

- **Specification:** آیا diff task، acceptance criteria و intent اعلام‌شده را برآورده می‌کند؟
- **Standards:** آیا با contractهای repo، skill، workflow و project سازگار است؟
- **Correctness:** آیا regression مشخص در state، data flow، boundary، API یا compatibility می‌سازد؟
- **Security and privacy:** آیا credential را افشا، permission را بی‌دلیل گسترده، input غیرقابل‌اعتماد را اجرا، injection را ممکن یا data را leak می‌کند؟
- **Performance and data access:** آیا network، database، filesystem، subprocess، polling یا per-item work نامحدود و غیرضروری می‌سازد؟
- **Tests and evidence:** آیا verification متناسب با behavior و ریسک تغییرکرده است؟
- **Review lifecycle:** آیا draft handling، retry، deduplication، line anchoring، reaction، thread state و convergence حفظ شده‌اند؟
- **False-positive filtering:** آیا تغییر در reviewer، evidence requirement، confidence filtering یا low-noise behavior را ضعیف کرده است؟

passهای مختص K2 عبارت‌اند از:

- **Strategy contract**
- **Condition audit**
- **Capital risk**
- **Order execution**
- **Backtest evidence**

هر specialist باید evidence تایپ‌شده و متناسب با domain خود برگرداند. finding مربوط به capital risk نمی‌تواند با جمله‌ی عمومی «این ریسک دارد» عبور کند؛ باید risk metric، authority پروژه، strategy contract یا رفتار مشخص source را نشان دهد.

### سه نوع check

judge فعلی findingها را زیر سه check سطح بالا دسته‌بندی می‌کند.

#### guidelineهای مهندسی به سبک Karpathy

این قواعد violation روشن درباره‌ی فکرکردن پیش از coding، سادگی، scope جراحی‌شده و verification goal-driven را می‌جویند. مجوز شکایت از هر abstraction یا فایل تغییرکرده نیستند. authority خاص‌تر K2 بر قاعده‌ی عمومی اولویت دارد.

#### داوری condition audit

این check pointer و evidence مربوط به condition audit تغییرکرده در strategy را ارزیابی می‌کند. می‌تواند metadata ناسازگار، technical role بدون پشتوانه، chronology stale، نبود validation در سطح condition، threshold توضیح‌نداده، overfit risk، ادعای بیش از حد درباره‌ی partial evidence و ریسک حل‌نشده‌ی capital-first را تشخیص دهد.

#### بازبینی حرفه‌ای Pull Request

این check mismatch با specification، violation استاندارد پروژه، correctness regression مشخص، risk امنیت یا privacy، risk performance یا data access، gap در test، regression در review lifecycle و ضعیف‌شدن false-positive filtering را پوشش می‌دهد.

rule idهای پایدار مهم‌اند. validation خروجی، metric، deduplication، learning و تغییر policy آینده را ممکن می‌کنند.
