import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/token_manager.dart';

class PayrollWidget extends StatefulWidget {
  final String? token;
  final String baseUrl;
  final int userId;

  const PayrollWidget({
    Key? key,
    this.token,
    required this.baseUrl,
    required this.userId,
  }) : super(key: key);

  @override
  State<PayrollWidget> createState() => _PayrollWidgetState();
}

class _PayrollWidgetState extends State<PayrollWidget> {
  // ── State ─────────────────────────────────────────────────────────────────
  final UserService _userService = UserService();

  List<Map<String, dynamic>> _payrollRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String? _error;

  String? _selectedPeriod;

  final Map<String, bool> _collapsed = {};

  // ── Colors ────────────────────────────────────────────────────────────────
  static const Color _grey300      = Color(0xFFE0E0E0);
  static const Color _grey400      = Color(0xFFBDBDBD);
  static const Color _grey600      = Color(0xFF757575);
  static const Color _divDark      = Color(0xFF424242);
  static const Color _divLight     = Color(0xFFEEEEEE);
  static const Color _greenAccent  = Color(0xFF43A047);
  static const Color _redAccent    = Color(0xFFEF5350);
  // static const Color _orangeAccent = Color(0xFFFB8C00);
  static const Color _blueGrey400  = Color(0xFF78909C);

  static const List<String> _sections = [
    'Allowances', 'Deductions', 'Adjustments', 'Loan Deductions',
  ];

  List<String> get _availablePeriods =>
      _payrollRecords.map((r) => r['period'] as String).toSet().toList();

  String get _token => TokenManager().token ?? widget.token ?? '';

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchPayrollRecords();
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> _fetchPayrollRecords() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      // Step 1 — fetch all active payroll periods via UserService
      final periodsResult = await _userService.getActivePayrollPeriods(_token);
      if (!periodsResult['success']) {
        setState(() {
          _error     = periodsResult['error'] ?? 'Failed to load payroll periods.';
          _isLoading = false;
        });
        return;
      }

      final periods = periodsResult['data'] as List<dynamic>;
      print('📋 [PayrollPage] ${periods.length} active period(s) found.');

      // Step 2 — fetch summary + pay components for each period in parallel
      final List<Map<String, dynamic>> records = [];
      for (final period in periods) {
        final periodId = period['id'] as int;

        // Run both requests at the same time
        final results = await Future.wait([
          _userService.getPayrollSummary(_token, widget.userId, periodId),
          _userService.getPayrollComponents(_token, widget.userId, periodId),
        ]);

        final summaryResult    = results[0];
        final componentsResult = results[1];

        if (summaryResult['success']) {
          // Summary may be a List or Map — normalise to Map
          final rawData = summaryResult['data'];
          final Map<String, dynamic> summaryMap = rawData is List
              ? (rawData.isNotEmpty
                  ? Map<String, dynamic>.from(rawData.first as Map)
                  : {})
              : Map<String, dynamic>.from(rawData as Map);

          // Components is always a List
          final List<dynamic> components = componentsResult['success']
              ? (componentsResult['data'] as List<dynamic>? ?? [])
              : [];

          records.add(_mapToRecord(
            period as Map<String, dynamic>,
            summaryMap,
            components,
          ));
        } else {
          print('⚠️ [PayrollPage] Skipping period $periodId: ${summaryResult['error']}');
        }
      }

      setState(() {
        _payrollRecords = records;
        if (_selectedPeriod == null && records.isNotEmpty) {
          _selectedPeriod = records.first['period'] as String?;
        }
        _applyFilters();
        _collapseAll();
        _isLoading = false;
      });
    } catch (e) {
      print('💥 [PayrollPage] Unexpected error: $e');
      setState(() {
        _error     = 'Unexpected error loading payroll.\n$e';
        _isLoading = false;
      });
    }
  }

  // ── Data mapping ──────────────────────────────────────────────────────────

  Map<String, dynamic> _mapToRecord(
    Map<String, dynamic> period,
    Map<String, dynamic> summary,
    List<dynamic> components,
  ) {
    final start = period['periodStart'] as String? ?? '';
    final end   = period['periodEnd']   as String? ?? '';

    String fmtDate(String iso) {
      try {
        final d = DateTime.parse(iso);
        const months = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December',
        ];
        return '${months[d.month]} ${d.day}';
      } catch (_) { return iso; }
    }

    String fmtYear(String iso) {
      try { return ', ${DateTime.parse(iso).year}'; } catch (_) { return ''; }
    }

    final periodLabel = '${fmtDate(start)}–${fmtDate(end)}${fmtYear(end)}';

    // Currency formatter: 8041.6 → "8,041.60"
    String? fmt(dynamic v) {
      if (v == null) return null;
      final d = (v is num) ? v.toDouble() : double.tryParse(v.toString());
      if (d == null) return null;
      final parts   = d.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final buf     = StringBuffer();
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buf.write(',');
        buf.write(intPart[i]);
        count++;
      }
      return '${buf.toString().split('').reversed.join()}.${parts[1]}';
    }

    // ── Parse pay components by type + adjustmentType ─────────────────────
    // Each entry wraps a payComponent object:
    //   type           → ALLOWANCE | DEDUCTION | LOAN_DEDUCTION
    //   adjustmentType → CR (credit → Allowances) | DR (debit → Deductions/Loans)
    final List<Map<String, dynamic>> allowanceItems   = [];
    final List<Map<String, dynamic>> deductionItems   = [];
    final List<Map<String, dynamic>> loanItems        = [];

    for (final entry in components) {
      // Exact API structure per item:
      // {
      //   adjustmentType: "CR" | "DR",      ← routing field (outer entry)
      //   pcAmount: 8041.6,                  ← the monetary value
      //   payComponent: {
      //     type: "ALLOWANCE" | "DEDUCTION" | "LOAN_DEDUCTION",
      //     allowance:   { allowanceDescription: "PERA" },   ← name for allowances
      //     deduction:   { deductionDescription: "..." },    ← name for deductions
      //     loanType:    { loanTypeName: "..." },            ← name for loans
      //     paymentPrincipal: ...                            ← loan principal (fallback)
      //   }
      // }
      final entryMap = entry as Map<String, dynamic>;
      final pc             = entryMap['payComponent'] as Map<String, dynamic>? ?? {};
      final type           = (pc['type']                       as String? ?? '').toUpperCase();
      final adjustmentType = (entryMap['adjustmentType']       as String? ?? '').toUpperCase();
      final amount         = entryMap['pcAmount']
                          ?? entryMap['amount']
                          ?? pc['allowanceAmount']
                          ?? pc['paymentPrincipal']
                          ?? pc['amount'];

      // Resolve display name from the nested sub-object matching the type
      String name;
      if (type == 'ALLOWANCE') {
        final allowance = pc['allowance'] as Map<String, dynamic>?;
        name = allowance?['allowanceDescription'] as String?
            ?? allowance?['allowanceCode'] as String?
            ?? 'Allowance';
      } else if (type == 'LOAN_DEDUCTION') {
        final loanType = pc['loanType'] as Map<String, dynamic>?;
        name = loanType?['loanTypeName'] as String?
            ?? loanType?['loanTypeCode'] as String?
            ?? 'Loan Deduction';
      } else {
        // DEDUCTION or unknown
        final deduction = pc['deduction'] as Map<String, dynamic>?;
        name = deduction?['deductionDescription'] as String?
            ?? deduction?['deductionCode'] as String?
            ?? pc['name'] as String?
            ?? _formatComponentName(type);
      }

      final item = {'name': name, 'amount': fmt(amount), 'raw': pc};

      if (type == 'LOAN_DEDUCTION') {
        loanItems.add(item);
      } else if (adjustmentType == 'CR') {
        allowanceItems.add(item);
      } else if (adjustmentType == 'DR') {
        deductionItems.add(item);
      }
    }

    // ── Summary totals ────────────────────────────────────────────────────
    final totalAllowances  = summary['totalAllowances'];
    final totalDeductions  = summary['totalDeductions'];
    final netPay           = summary['netPay']   ?? summary['netIncome'];
    final basicPay         = summary['basicPay'] ?? summary['basicSalary'] ?? summary['monthlySalary'];
    final totalLoanDeduction = summary['totalLoanDeductions'];
    final phicContribution = summary['philhealthContribution']
        ?? summary['phicContribution']
        ?? summary['philHealth'];

    // Total Earnings = basicPay + totalAllowances (computed — not a direct API field)
    final double basicPayD     = (basicPay       is num) ? basicPay.toDouble()       : double.tryParse(basicPay?.toString()       ?? '') ?? 0.0;
    final double allowancesD   = (totalAllowances is num) ? totalAllowances.toDouble() : double.tryParse(totalAllowances?.toString() ?? '') ?? 0.0;
    final double totalEarnings = basicPayD + allowancesD;

    //Total Deductions = totalDeductions + totalLoanDeduction (computed — not a direct API field)
    final double deductionsD   = (totalDeductions is num) ? totalDeductions.toDouble() : double.tryParse(totalDeductions?.toString() ?? '') ?? 0.0;
    final double loanDeductionD = (totalLoanDeduction is num) ? totalLoanDeduction.toDouble() : double.tryParse(totalLoanDeduction?.toString() ?? '') ?? 0.0;
    final double totalDeductions2 = deductionsD + loanDeductionD;

    return {
      'period':            periodLabel,
      'periodDate':        end,
      'netIncome':         fmt(netPay),
      'monthlySalary':     fmt(basicPay),
      'totalEarnings':     fmt(totalEarnings),
      'totalDeductions':   fmt(totalDeductions2),
      'totalAllowances':   fmt(totalAllowances),
      'phicContribution':  fmt(phicContribution),
      'totalDeductions2':  fmt(totalDeductions),
      // Component lists for the UI sections
      'allowanceItems':    allowanceItems,   // CR items → Allowances section
      'deductionItems':    deductionItems,   // DR items → Deductions section
      'loanItems':         loanItems,        // LOAN_DEDUCTION items → Loan Deductions section
    };
  }

  /// Converts a raw type string like "LOAN_DEDUCTION" → "Loan Deduction"
  String _formatComponentName(String type) {
    return type
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  // ── Filter / collapse helpers ─────────────────────────────────────────────

  void _applyFilters() {
    _filteredRecords = _payrollRecords
        .where((r) => _selectedPeriod == null || r['period'] == _selectedPeriod)
        .toList();
  }

  void _collapseAll() {
    for (final record in _payrollRecords) {
      final String pd = record['periodDate'] ?? '';
      for (final section in _sections) {
        _collapsed['${pd}_$section'] = true;
      }
    }
  }

  bool _isCollapsed(String pd, String section) =>
      _collapsed['${pd}_$section'] ?? false;

  void _toggleCollapse(String pd, String section) {
    setState(() {
      final key = '${pd}_$section';
      _collapsed[key] = !(_collapsed[key] ?? false);
    });
  }

  // ─── Filter bottom sheet ──────────────────────────────────────────────────

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: _grey300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                Text('Filter by Payroll Period',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF587CA5)
                            : Theme.of(context).primaryColor)),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _availablePeriods.map((period) {
                    final bool sel = _selectedPeriod == period;
                    return ChoiceChip(
                      label: Center(child: Text(period)),
                      selected: sel,
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          _selectedPeriod = sel ? null : period;
                          _applyFilters();
                        });
                        Navigator.pop(ctx);
                      },
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                          color: sel
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF587CA5)
                                  : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500),
                      side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF587CA5)
                              : Theme.of(context).primaryColor),
                      backgroundColor: Colors.transparent,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Summary modal ────────────────────────────────────────────────────────

  void _showSummaryModal(Map<String, dynamic> record) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final Color textColor   = isDark ? Colors.white : Colors.black87;
    final Color subColor    = isDark ? _grey400 : _grey600;
    final Color divColor    = isDark ? _divDark : _divLight;
    final Color headerColor =
        isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: _grey300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.summarize_outlined, color: headerColor, size: 18),
                const SizedBox(width: 8),
                Text('Payroll Summary',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: headerColor)),
                const Spacer(),
                Text(record['period'] ?? '',
                    style: TextStyle(fontSize: 11, color: headerColor)),
              ],
            ),
            const SizedBox(height: 6),
            Divider(color: divColor),
            const SizedBox(height: 4),
            _summaryLine('Monthly Salary',   record['monthlySalary'],  textColor, subColor, headerColor),
            _summaryLine('Total Earnings',   record['totalEarnings'],  textColor, subColor, headerColor),
            _summaryLine('Total Deductions', record['totalDeductions'], textColor, subColor, _redAccent),
            const SizedBox(height: 8),
            Divider(color: divColor),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Income',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                Text(
                  record['netIncome'] != null ? '₱${record['netIncome']}' : '—',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: headerColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(String label, dynamic value, Color textColor,
      Color subColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: subColor, fontWeight: FontWeight.w500)),
          Text(
            value != null ? '₱${value.toString()}' : '—',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }

  // ─── Main build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPayrollRecords,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Header bar ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PAYROLL',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: const Icon(Icons.filter_list,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      final target = _filteredRecords.isNotEmpty
                          ? _filteredRecords.first
                          : _payrollRecords.isNotEmpty
                              ? _payrollRecords.first
                              : null;
                      if (target != null) _showSummaryModal(target);
                    },
                    child: const Icon(Icons.summarize_outlined,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _fetchPayrollRecords,
                    child: const Icon(Icons.refresh,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Records list ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _payrollRecords.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No payroll records available',
                        style: TextStyle(fontSize: 16)),
                  ),
                )
              : _filteredRecords.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('No records found for selected filters',
                            style: TextStyle(fontSize: 14)),
                      ),
                    )
                  : Column(
                      children: _filteredRecords
                          .map((r) => _buildPayrollRecord(r))
                          .toList(),
                    ),
        ),
      ],
    );
  }

  // ─── Full payroll record block ─────────────────────────────────────────────

  Widget _buildPayrollRecord(Map<String, dynamic> record) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final Color primary   = Theme.of(context).primaryColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor  = isDark ? _grey400 : _grey600;
    final String pd       = record['periodDate'] ?? '';

    final allowanceItems = (record['allowanceItems'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final deductionItems = (record['deductionItems'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final loanItems      = (record['loanItems'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period header
        Row(
          children: [
            Icon(Icons.receipt_long,
                size: 18, color: isDark ? Colors.white70 : primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(record['period'] ?? 'N/A',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : primary)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Allowances (adjustmentType == CR) ────────────────────────────
        _sectionBlock(
          pd: pd, title: 'Allowances', icon: Icons.add_circle_outline,
          rows: allowanceItems.isEmpty
              ? [_emptyRow('No allowances for this period.', subColor)]
              : allowanceItems
                  .map((item) => _rowLine(
                        item['name'] as String,
                        item['amount'],
                        textColor,
                        subColor,
                      ))
                  .toList(),
          totalLabel: 'Total Allowances',
          totalValue: record['totalAllowances'],
          totalAccent: _greenAccent,
          textColor: textColor, subColor: subColor,
        ),
        const SizedBox(height: 14),

        // ── Deductions (adjustmentType == DR, non-loan) ───────────────────
        _sectionBlock(
          pd: pd, title: 'Deductions', icon: Icons.remove_circle_outline,
          rows: deductionItems.isEmpty
              ? [_emptyRow('No deductions for this period.', subColor)]
              : deductionItems
                  .map((item) => _rowLine(
                        item['name'] as String,
                        item['amount'],
                        textColor,
                        subColor,
                      ))
                  .toList(),
          totalLabel: 'Total Deductions',
          totalValue: record['totalDeductions2'],
          totalAccent: _redAccent,
          textColor: textColor, subColor: subColor,
        ),
        const SizedBox(height: 14),

        // ── Loan Deductions (type == LOAN_DEDUCTION) ──────────────────────
        _sectionBlock(
          pd: pd, title: 'Loan Deductions', icon: Icons.account_balance_outlined,
          rows: loanItems.isEmpty
              ? [_emptyRow('No loan deductions for this period.', subColor)]
              : loanItems
                  .map((item) => _rowLine(
                        item['name'] as String,
                        item['amount'],
                        textColor,
                        subColor,
                      ))
                  .toList(),
          totalLabel: null, totalValue: null,
          totalAccent: _blueGrey400,
          textColor: textColor, subColor: subColor,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Section block ─────────────────────────────────────────────────────────

  Widget _sectionBlock({
    required String pd,
    required String title,
    required IconData icon,
    required List<Widget> rows,
    required String? totalLabel,
    required dynamic totalValue,
    required Color totalAccent,
    required Color textColor,
    required Color subColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerColor =
        isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;
    final bool collapsed = _isCollapsed(pd, title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleCollapse(pd, title),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(icon, size: 15, color: headerColor),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: headerColor)),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    thickness: 1),
              ),
              const SizedBox(width: 6),
              Icon(
                collapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 18, color: headerColor,
              ),
            ],
          ),
        ),
        if (!collapsed) ...[
          const SizedBox(height: 4),
          ...rows,
          if (totalLabel != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(totalLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                Text(
                  totalValue != null ? '₱${totalValue.toString()}' : '—',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: totalAccent),
                ),
              ],
            ),
          const SizedBox(height: 10),
        ] else
          const SizedBox(height: 4),
      ],
    );
  }

  // ─── Row helpers ───────────────────────────────────────────────────────────

  Widget _rowLine(String label, dynamic value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: subColor)),
          Text(
            value != null ? '₱${value.toString()}' : '—',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _emptyRow(String message, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(message,
          style: TextStyle(
              fontSize: 12, color: subColor, fontStyle: FontStyle.italic)),
    );
  }
}