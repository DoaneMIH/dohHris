import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/config/api_config.dart';
import 'dart:convert';
import '../services/token_manager.dart';

class PayrollWidget extends StatefulWidget {
  final String? token;
  final String baseUrl;
  final String userId;

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
  List<Map<String, dynamic>> _payrollRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String? _error;

  String? _selectedPeriod; // e.g. "January 1–31, 2026"
  int? _selectedMonth;

  // Track collapsed state per record+section
  // Key: "${record['periodDate']}_${sectionTitle}"
  final Map<String, bool> _collapsed = {};

  final List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  // ── All colors as static const ────────────────────────────────────────────
  static const Color _grey300      = Color(0xFFE0E0E0);
  static const Color _grey400      = Color(0xFFBDBDBD);
  static const Color _grey600      = Color(0xFF757575);
  static const Color _divDark      = Color(0xFF424242);
  static const Color _divLight     = Color(0xFFEEEEEE);
  static const Color _greenAccent  = Color(0xFF43A047);
  static const Color _redAccent    = Color(0xFFEF5350);
  static const Color _orangeAccent = Color(0xFFFB8C00);
  static const Color _blueGrey400  = Color(0xFF78909C);

  // ── Dummy data ────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _dummyRecords = [
    {
      'period':            'January 1–31, 2026',
      'periodDate':        '2026-01-31',
      'netIncome':         '41,202.80',
      'monthlySalary':     '40,208.00',
      'totalEarnings':     '42,208.00',
      'totalDeductions':   '-1,005.20',
      'hazardPay':         '2,000.00',
      'totalAllowances':   '2,000.00',
      'phicContribution':  '1,005.20',
      'totalDeductions2':  '1,005.20',
      'adjustmentAmount':  null,
      'loanDeduction':     null,
    },
    {
      'period':            'December 1–31, 2025',
      'periodDate':        '2025-12-31',
      'netIncome':         '19,850.50',
      'monthlySalary':     '20,104.00',
      'totalEarnings':     '21,104.00',
      'totalDeductions':   '-1,253.50',
      'hazardPay':         '1,000.00',
      'totalAllowances':   '1,000.00',
      'phicContribution':  '502.60',
      'totalDeductions2':  '1,253.50',
      'adjustmentAmount':  null,
      'loanDeduction':     '750.90',
    },
  ];

  // ── Build the list of selectable period labels from the records ───────────
  List<String> get _availablePeriods =>
      _payrollRecords.map((r) => r['period'] as String).toSet().toList();




  @override
  void initState() {
    super.initState();
    _fetchPayrollRecords();
  }

  Future<void> _fetchPayrollRecords() async {
    setState(() { _isLoading = true; _error = null; });

    // TODO: Replace with actual API call when endpoint is ready
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _payrollRecords = List<Map<String, dynamic>>.from(_dummyRecords);

        if (_selectedPeriod == null && _payrollRecords.isNotEmpty) {
    _selectedPeriod = _payrollRecords.first['period'] as String?;
  }
  
      _applyFilters();
      _collapseAll();
      _isLoading = false;
    });
  }

  

  void _applyFilters() {
    _filteredRecords = _payrollRecords.where((record) {
      final periodOk = _selectedPeriod == null ||
          record['period'] == _selectedPeriod;
      if (_selectedMonth != null) {
        try {
          final date = DateTime.parse(record['periodDate'] ?? '');
          return periodOk && date.month == _selectedMonth;
        } catch (_) {
          return false;
        }
      }
      return periodOk;
    }).toList();
  }

  // ── Collapse key helper ───────────────────────────────────────────────────
  static const List<String> _sections = [
    'Allowances', 'Deductions', 'Adjustments', 'Loan Deductions',
  ];

  /// Pre-collapse every section of every record on first load.
  void _collapseAll() {
    for (final record in _payrollRecords) {
      final String periodDate = record['periodDate'] ?? '';
      for (final section in _sections) {
        _collapsed['${periodDate}_$section'] = true;
      }
    }
  }

  bool _isCollapsed(String periodDate, String section) =>
      _collapsed['${periodDate}_$section'] ?? false;

  void _toggleCollapse(String periodDate, String section) {
    setState(() {
      final key = '${periodDate}_$section';
      _collapsed[key] = !(_collapsed[key] ?? false);
    });
  }


  // ─── Option picker bottom sheet ──────────────────────────────────────────────

  Future<void> _showOptionsBottomSheet({
    required BuildContext ctx,
    required String title,
    required List<String> options,
    required String? currentValue,
    required void Function(String) onSelected,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet(
      context: ctx,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.6),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF587CA5)
                            : Theme.of(context).primaryColor)),
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final sel = opt == currentValue;
                  return InkWell(
                    onTap: () { onSelected(opt); Navigator.of(sheetCtx).pop(); },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: sel
                          ? Theme.of(context).primaryColor.withOpacity(0.08)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(opt,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: sel
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                          if (sel)
                            Icon(Icons.check, size: 18,
                                color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Period filter bottom sheet ──────────────────────────────────────────────
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
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,  
    ),  
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Filter by Payroll Period',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF587CA5)
                      : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _availablePeriods.map((period) {
                  final bool selected = _selectedPeriod == period;
                  return Padding(
                    padding: EdgeInsets.zero,  // ← Add spacing between chips
                    child: SizedBox(
                      width: double.infinity,  // ← Full width
                      child: ChoiceChip(
                        label: Center(child: Text(period)),  // ← Center text
                        selected: selected,
                        showCheckmark: false,  
                        onSelected: (_) {
                          setState(() {
                            _selectedPeriod = selected ? null : period;
                            _applyFilters();
                          });
                          Navigator.pop(ctx);
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF587CA5)
                                  : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF587CA5)
                              : Theme.of(context).primaryColor,
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
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

  Widget _filterBtn({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        backgroundColor: selected
            ? Theme.of(context).primaryColor.withOpacity(0.10)
            : null,
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF587CA5)
              : Theme.of(context).primaryColor,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF587CA5)
                  : Theme.of(context).primaryColor,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
          overflow: TextOverflow.ellipsis),
    );
  }

  // ─── Summary modal ───────────────────────────────────────────────────────────

  void _showSummaryModal(Map<String, dynamic> record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor  = isDark ? _grey400 : _grey600;
    final Color divColor  = isDark ? _divDark : _divLight;
    final Color headerColor =
        isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: _grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
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
            _summaryLine('Monthly Salary',  record['monthlySalary'],
                textColor, subColor, headerColor),
            _summaryLine('Total Earnings',  record['totalEarnings'],
                textColor, subColor, headerColor),
            _summaryLine('Total Deductions', record['totalDeductions'],
                textColor, subColor, _redAccent),
            const SizedBox(height: 8),
            Divider(color: divColor),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Net Income',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Text(
                  record['netIncome'] != null
                      ? '₱${record['netIncome']}'
                      : '—',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: headerColor),
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

  // ─── Main build ──────────────────────────────────────────────────────────────

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
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ── Header bar ────────────────────────────────────────────────────────
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
              const Text(
                'PAYROLL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
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
                ],
              ),
            ],
          ),
        ),

        // ── Records list ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _payrollRecords.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No payroll records available',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : _filteredRecords.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'No records found for selected filters',
                          style: TextStyle(fontSize: 14),
                        ),
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

  // ─── Full payroll record block ────────────────────────────────────────────────

  Widget _buildPayrollRecord(Map<String, dynamic> record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary   = Theme.of(context).primaryColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor  = isDark ? _grey400 : _grey600;

    final bool noAdjustment = record['adjustmentAmount'] == null;
    final bool noLoan       = record['loanDeduction'] == null;
    final String periodDate = record['periodDate'] ?? '';

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
              child: Text(
                record['period'] ?? 'N/A',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // ── Allowances ────────────────────────────────────────────────────────
        _sectionBlock(
          periodDate: periodDate,
          title: 'Allowances',
          icon: Icons.add_circle_outline,
          rows: [
            _rowLine('Hazard Pay', record['hazardPay'], textColor, subColor),
          ],
          totalLabel: 'Total Allowances',
          totalValue: record['totalAllowances'],
          totalAccent: _greenAccent,
          textColor: textColor,
          subColor: subColor,
        ),
        const SizedBox(height: 14),

        // ── Deductions ────────────────────────────────────────────────────────
        _sectionBlock(
          periodDate: periodDate,
          title: 'Deductions',
          icon: Icons.remove_circle_outline,
          rows: [
            _rowLine('PHIC Contribution',
                record['phicContribution'], textColor, subColor),
          ],
          totalLabel: 'Total Deductions',
          totalValue: record['totalDeductions2'],
          totalAccent: _redAccent,
          textColor: textColor,
          subColor: subColor,
        ),
        const SizedBox(height: 14),

        // ── Adjustments ───────────────────────────────────────────────────────
        _sectionBlock(
          periodDate: periodDate,
          title: 'Adjustments',
          icon: Icons.tune_outlined,
          rows: [
            noAdjustment
                ? _emptyRow('No adjustments for this period.', subColor)
                : _rowLine('Adjustment Amount',
                    record['adjustmentAmount'], textColor, subColor),
          ],
          totalLabel: null,
          totalValue: null,
          totalAccent: _orangeAccent,
          textColor: textColor,
          subColor: subColor,
        ),
        const SizedBox(height: 14),

        // ── Loan Deductions ───────────────────────────────────────────────────
        _sectionBlock(
          periodDate: periodDate,
          title: 'Loan Deductions',
          icon: Icons.account_balance_outlined,
          rows: [
            noLoan
                ? _emptyRow('No loan deductions for this period.', subColor)
                : _rowLine('Loan Deduction',
                    record['loanDeduction'], textColor, subColor),
          ],
          totalLabel: null,
          totalValue: null,
          totalAccent: _blueGrey400,
          textColor: textColor,
          subColor: subColor,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Section block with collapse toggle ──────────────────────────────────────

  Widget _sectionBlock({
    required String periodDate,
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
    final bool collapsed = _isCollapsed(periodDate, title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with collapse toggle at the end
        GestureDetector(
          onTap: () => _toggleCollapse(periodDate, title),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(icon, size: 15, color: headerColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                collapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 18,
                color: headerColor,
              ),
            ],
          ),
        ),
        // Collapsible content
        if (!collapsed) ...[
          const SizedBox(height: 4),
          ...rows,
          if (totalLabel != null) ...[
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
          ],
          const SizedBox(height: 10),
        ] else
          const SizedBox(height: 4),
      ],
    );
  }

  // ─── Label / value row ────────────────────────────────────────────────────────

  Widget _rowLine(
      String label, dynamic value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: subColor)),
          Text(
            value != null ? '₱${value.toString()}' : '—',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor),
          ),
        ],
      ),
    );
  }

  // ─── Empty state row ──────────────────────────────────────────────────────────

  Widget _emptyRow(String message, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        message,
        style: TextStyle(
            fontSize: 12,
            color: subColor,
            fontStyle: FontStyle.italic),
      ),
    );
  }
}