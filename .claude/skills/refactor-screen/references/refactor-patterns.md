# リファクタパターン集

既存コードのスタイル（`BookingScreen` / `HomeScreen` / `PlanDetailScreen`）に合わせたテンプレート。

---

## パターン 1: ウィザード形式（--wizard）

### 1-A: ViewModel への currentStep 追加

既存の State クラス（例: `BookingFormState`）に追加するフィールドとメソッド:

```dart
// State クラスに追加
class BookingFormState {
  // ... 既存フィールド ...
  final int currentStep;   // 0 始まり
  final int totalSteps;    // ウィザードのステップ総数（固定値）

  const BookingFormState({
    // ... 既存パラメータ ...
    this.currentStep = 0,
    this.totalSteps = 3,   // ステップ数に合わせて変更
  });

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;

  BookingFormState copyWith({
    // ... 既存パラメータ ...
    int? currentStep,
    int? totalSteps,
    // ... 既存フラグ ...
  }) {
    return BookingFormState(
      // ... 既存フィールド ...
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}
```

ViewModel クラスに追加するメソッド:

```dart
// ステップ移動
void nextStep() {
  if (state.currentStep < state.totalSteps - 1) {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }
}

void previousStep() {
  if (state.currentStep > 0) {
    state = state.copyWith(currentStep: state.currentStep - 1, clearError: true);
  }
}

// ステップ固有バリデーション（例: 3ステップ構成）
bool validateCurrentStep() {
  final errors = <String, String>{};

  switch (state.currentStep) {
    case 0:
      // ステップ 1 のバリデーション
      if (state.customerName.trim().isEmpty) {
        errors['customerName'] = 'お名前を入力してください';
      }
      if (state.customerEmail.trim().isEmpty) {
        errors['customerEmail'] = 'メールアドレスを入力してください';
      } else if (!state.customerEmail.contains('@')) {
        errors['customerEmail'] = '有効なメールアドレスを入力してください';
      }
      if (state.customerPhone.trim().isEmpty) {
        errors['customerPhone'] = '電話番号を入力してください';
      }
    case 1:
      // ステップ 2 のバリデーション
      if (state.numberOfPeople < 1) {
        errors['numberOfPeople'] = '参加人数は1名以上を指定してください';
      }
      if (state.travelDate == null) {
        errors['travelDate'] = '旅行日を選択してください';
      } else if (state.travelDate!.isBefore(DateTime.now())) {
        errors['travelDate'] = '旅行日は本日以降の日付を選択してください';
      }
    default:
      break; // 最終ステップはバリデーション不要
  }

  if (errors.isNotEmpty) {
    state = state.copyWith(validationErrors: errors);
    return false;
  }
  return true;
}
```

### 1-B: ステップインジケーターウィジェット

`lib/presentation/screens/<name>/steps/` 配下または Screen ファイル内のプライベートウィジェット:

```dart
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels; // 例: ['お客様情報', '予約内容', '確認']

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isDone = index < currentStep;
          return Expanded(
            child: Row(
              children: [
                _StepDot(index: index, isActive: isActive, isDone: isDone),
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? AppTheme.primaryColor : AppTheme.dividerColor,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDone;

  const _StepDot({
    required this.index,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? AppTheme.primaryColor
            : isActive
                ? AppTheme.primaryColor
                : AppTheme.surfaceColor,
        border: Border.all(
          color: isActive || isDone ? AppTheme.primaryColor : AppTheme.dividerColor,
          width: 2,
        ),
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppTheme.textHint,
                ),
              ),
      ),
    );
  }
}
```

### 1-C: ウィザードナビゲーション（次へ/戻るボタン）

メイン Screen の `bottomNavigationBar` または `body` 末尾に配置:

```dart
// bottomNavigationBar として配置する場合
Widget _buildNavigationBar(BuildContext context, BookingFormState state) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (!state.isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    ref.read(bookingViewModelProvider.notifier).previousStep(),
                child: const Text('戻る'),
              ),
            ),
          if (!state.isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: state.isFirstStep ? 1 : 1,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : () => _onNextOrSubmit(state),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        state.isLastStep ? '予約を確定する' : '次へ',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// 次へ押下時の処理
void _onNextOrSubmit(BookingFormState state) {
  final notifier = ref.read(bookingViewModelProvider.notifier);
  if (state.isLastStep) {
    _submitBooking(/* 引数 */);
  } else {
    if (notifier.validateCurrentStep()) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
```

### 1-D: 各ステップの StatelessWidget テンプレート

`lib/presentation/screens/<name>/steps/<step_name>_step.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
// 必要に応じて ViewModel の State クラスをインポート

class CustomerInfoStep extends StatelessWidget {
  // ViewModel の State から必要な値をコンストラクタ引数で受け取る
  final String? customerNameError;
  final String? customerEmailError;
  final String? customerPhoneError;
  final void Function(String) onNameChanged;
  final void Function(String) onEmailChanged;
  final void Function(String) onPhoneChanged;

  const CustomerInfoStep({
    super.key,
    this.customerNameError,
    this.customerEmailError,
    this.customerPhoneError,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // セクションタイトル
        const Text(
          'お客様情報',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const Gap(16),
        // フィールド群
        TextFormField(
          decoration: InputDecoration(
            labelText: 'お名前（代表者）',
            hintText: '山田 太郎',
            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            errorText: customerNameError,
          ),
          onChanged: onNameChanged,
        ),
        const Gap(12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'メールアドレス',
            hintText: 'example@email.com',
            prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
            errorText: customerEmailError,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: onEmailChanged,
        ),
        const Gap(12),
        TextFormField(
          decoration: InputDecoration(
            labelText: '電話番号',
            hintText: '090-1234-5678',
            prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
            errorText: customerPhoneError,
          ),
          keyboardType: TextInputType.phone,
          onChanged: onPhoneChanged,
        ),
      ],
    );
  }
}
```

### 1-E: メイン Screen のステップコントローラー構成

```dart
class BookingScreen extends ConsumerStatefulWidget {
  final String planId;
  const BookingScreen({super.key, required this.planId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingViewModelProvider);
    // ... plan の読み込み ...

    return Scaffold(
      appBar: AppBar(
        title: const Text('予約する'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepIndicator(
            currentStep: state.currentStep,
            totalSteps: state.totalSteps,
            stepLabels: const ['お客様情報', '予約内容', '確認'],
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.totalSteps,
        itemBuilder: (context, index) => _buildStep(index, state),
      ),
      bottomNavigationBar: _buildNavigationBar(context, state),
    );
  }

  Widget _buildStep(int index, BookingFormState state) {
    final notifier = ref.read(bookingViewModelProvider.notifier);
    return switch (index) {
      0 => CustomerInfoStep(
          customerNameError: state.validationErrors['customerName'],
          customerEmailError: state.validationErrors['customerEmail'],
          customerPhoneError: state.validationErrors['customerPhone'],
          onNameChanged: notifier.updateCustomerName,
          onEmailChanged: notifier.updateCustomerEmail,
          onPhoneChanged: notifier.updateCustomerPhone,
        ),
      1 => BookingDetailsStep(/* 引数 */),
      2 => ConfirmationStep(/* 引数 */),
      _ => const SizedBox.shrink(),
    };
  }
}
```

---

## パターン 2: ウィジェット抽出（--extract-widgets）

### 2-A: 抽出後のウィジェットファイルテンプレート

スクリーン固有ウィジェット（`lib/presentation/screens/<name>/widgets/<widget_name>.dart`）:

```dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
// 必要な model や State をインポート

/// 料金内訳カード
///
/// BookingScreen の料金表示セクションを抽出したウィジェット。
class PriceBreakdownCard extends StatelessWidget {
  final double pricePerPerson;
  final int numberOfPeople;
  final bool hasDiscount;
  final double originalPrice;

  const PriceBreakdownCard({
    super.key,
    required this.pricePerPerson,
    required this.numberOfPeople,
    required this.hasDiscount,
    required this.originalPrice,
  });

  double get total => pricePerPerson * numberOfPeople;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '料金内訳',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const Gap(12),
          // ... 内訳行 ...
        ],
      ),
    );
  }
}
```

共通ウィジェット（`lib/presentation/widgets/<widget_name>.dart`）:

```dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// セクションタイトル
///
/// 複数のフォーム画面で共通して使われるセクション見出し。
class SectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.padding = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
```

### 2-B: メイン Screen からの参照パターン（抽出前後の比較）

**抽出前:**
```dart
// screen ファイル内の _buildPriceBreakdown が 40行以上ある
Widget _buildPriceBreakdown(TravelPlan plan, BookingFormState state) {
  // 40行のコード ...
}
```

**抽出後:**
```dart
// Screen 内は1行に
PriceBreakdownCard(
  pricePerPerson: plan.effectivePrice,
  numberOfPeople: state.numberOfPeople,
  hasDiscount: plan.hasDiscount,
  originalPrice: plan.price,
),
```

---

## パターン 3: 分割パターン（--split）

### 3-A: 親子ウィジェット構成テンプレート

大きな Screen を子ウィジェットに委譲するパターン。
子ウィジェットは `ConsumerWidget` として ViewModel を直接 watch する。

**メイン Screen（親）:**

```dart
class BookingScreen extends ConsumerStatefulWidget {
  // ... 変更なし ...

  @override
  Widget build(BuildContext context) {
    // plan ロード処理は親が持つ
    final plan = ref.watch(planDetailViewModelProvider(widget.planId)).plan;
    if (plan == null) return const Scaffold(body: LoadingIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('予約する')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 分割した子ウィジェットを並べる
            BookingPlanSummarySection(plan: plan),
            const Gap(24),
            const BookingCustomerInfoSection(),  // ViewModel を内部で watch
            const Gap(24),
            BookingDetailsSection(plan: plan),
            const Gap(24),
            BookingPriceSummarySection(plan: plan),
            const Gap(16),
            const BookingSubmitSection(),        // エラー表示 + 送信ボタン
            const Gap(32),
          ],
        ),
      ),
    );
  }
}
```

**子ウィジェット（ConsumerWidget で ViewModel を直接 watch）:**

```dart
// lib/presentation/screens/booking/widgets/booking_customer_info_section.dart

class BookingCustomerInfoSection extends ConsumerWidget {
  const BookingCustomerInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingViewModelProvider);
    final notifier = ref.read(bookingViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'お客様情報',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const Gap(12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'お名前（代表者）',
            hintText: '山田 太郎',
            prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            errorText: state.validationErrors['customerName'],
          ),
          onChanged: notifier.updateCustomerName,
        ),
        // ... 他フィールド ...
      ],
    );
  }
}
```

### 3-B: 分割の判断基準

| 分割方針 | 適するケース |
|---|---|
| **子が ConsumerWidget** | 子が ViewModel の特定フィールドだけを監視する場合（リビルド最適化） |
| **子が StatelessWidget** | 子が表示専用で全データを引数で受け取る場合（テストしやすい） |
| **子が ConsumerStatefulWidget** | 子がローカル状態（TextEditingController 等）と ViewModel の両方を持つ場合 |

---

## 命名規約

| 種別 | 命名例 |
|---|---|
| ステップファイル | `customer_info_step.dart` → `class CustomerInfoStep` |
| セクションウィジェット（スクリーン固有） | `booking_customer_info_section.dart` → `class BookingCustomerInfoSection` |
| 共通ウィジェット | `section_title.dart` → `class SectionTitle` |
| ステップディレクトリ | `screens/booking/steps/` |
| セクションディレクトリ | `screens/booking/widgets/` |
