import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_application/config/api_config.dart';
import 'dart:convert';
import '../services/token_manager.dart';

class LoanWidget extends StatefulWidget {
  final String? token;
  final String baseUrl;
  final String userId;

  const LoanWidget({
    Key? key,
    this.token,
    required this.baseUrl,
    required this.userId,
  }) : super(key: key);

  @override
  State<LoanWidget> createState() => _LoanWidgetState();
}

class _LoanWidgetState extends State<LoanWidget> {
  List<Map<String, dynamic>> _loanRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedLoanType;

  // ── Collapse state ────────────────────────────────────────────────────────
  // Key: "${loanType}_${entryNo}"  → individual card
  // Key: "${loanType}_all"         → whether ALL cards in that loan are collapsed
  final Map<String, bool> _collapsed = {};

  // ── Static const colors ───────────────────────────────────────────────────
  static const Color _grey300      = Color(0xFFE0E0E0);
  static const Color _grey400      = Color(0xFFBDBDBD);
  static const Color _grey600      = Color(0xFF757575);
  static const Color _divDark      = Color(0xFF424242);
  static const Color _divLight     = Color(0xFFEEEEEE);
  static const Color _paidColor    = Color(0xFF43A047);
  static const Color _activeColor  = Color(0xFF1E88E5);
  static const Color _pendingColor = Color(0xFFFB8C00);

  // ── Dummy data ────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _dummyLoans = [
    {
      'loanType':            'COOP Loan',
      'loanAmount':          '10,000.00',
      'interestComputation': 'Percent',
      'interest':            '15%',
      'amortizationType':    'Monthly',
      'noOfAmortizations':   12,
      'firstPayment':        'January 5, 2026',
      'paymentProgress':     '1 / 12 payments',
      'loanStatus':          'Active',
      'schedule': [
        {'no':  1, 'date': 'January 5, 2026',   'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Paid'},
        {'no':  2, 'date': 'February 5, 2026',  'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  3, 'date': 'March 5, 2026',     'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  4, 'date': 'April 5, 2026',     'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  5, 'date': 'May 5, 2026',       'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  6, 'date': 'June 5, 2026',      'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  7, 'date': 'July 5, 2026',      'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  8, 'date': 'August 5, 2026',    'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no':  9, 'date': 'September 5, 2026', 'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no': 10, 'date': 'October 5, 2026',   'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no': 11, 'date': 'November 5, 2026',  'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
        {'no': 12, 'date': 'December 5, 2026',  'principal': '833.33', 'interest': '125.00', 'totalPayment': '958.33', 'status': 'Pending'},
      ],
      'totalPrincipal': '10,000.00',
      'totalInterest':  '1,500.00',
      'grandTotal':     '11,500.00',
    },
    {
      'loanType':            'GSIS Loan',
      'loanAmount':          '50,000.00',
      'interestComputation': 'Percent',
      'interest':            '6%',
      'amortizationType':    'Monthly',
      'noOfAmortizations':   24,
      'firstPayment':        'February 1, 2025',
      'paymentProgress':     '14 / 24 payments',
      'loanStatus':          'Active',
      'schedule': [
        {'no':  1, 'date': 'February 1, 2025',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  2, 'date': 'March 1, 2025',     'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  3, 'date': 'April 1, 2025',     'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  4, 'date': 'May 1, 2025',       'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  5, 'date': 'June 1, 2025',      'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  6, 'date': 'July 1, 2025',      'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  7, 'date': 'August 1, 2025',    'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  8, 'date': 'September 1, 2025', 'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no':  9, 'date': 'October 1, 2025',   'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 10, 'date': 'November 1, 2025',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 11, 'date': 'December 1, 2025',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 12, 'date': 'January 1, 2026',   'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 13, 'date': 'February 1, 2026',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 14, 'date': 'March 1, 2026',     'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Paid'},
        {'no': 15, 'date': 'April 1, 2026',     'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 16, 'date': 'May 1, 2026',       'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 17, 'date': 'June 1, 2026',      'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 18, 'date': 'July 1, 2026',      'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 19, 'date': 'August 1, 2026',    'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 20, 'date': 'September 1, 2026', 'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 21, 'date': 'October 1, 2026',   'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 22, 'date': 'November 1, 2026',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 23, 'date': 'December 1, 2026',  'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
        {'no': 24, 'date': 'January 1, 2027',   'principal': '2,083.33', 'interest': '250.00', 'totalPayment': '2,333.33', 'status': 'Pending'},
      ],
      'totalPrincipal': '50,000.00',
      'totalInterest':  '6,000.00',
      'grandTotal':     '56,000.00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLoanRecords();
  }

  Future<void> _fetchLoanRecords() async {
    setState(() { _isLoading = true; _error = null; });

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _loanRecords = List<Map<String, dynamic>>.from(_dummyLoans);
      _applyFilters();
      _collapseAll();
      _isLoading = false;
    });
  }

  List<String> get _loanTypes { 
    final types = _loanRecords.map((r) => r['loanType'].toString()).toSet().toList();
    types.sort();
    return types;
  }

  void _applyFilters() {
    _filteredRecords = _loanRecords.where((r) =>
        _selectedLoanType == null || r['loanType'] == _selectedLoanType,
    ).toList();
  }

  /// Pre-collapse every card and every group on first load.
  void _collapseAll() {
    for (final loan in _loanRecords) {
      final String loanType        = loan['loanType'].toString();
      final List<dynamic> schedule = (loan['schedule'] as List<dynamic>?) ?? [];
      _collapsed[_allKey(loanType)] = true;
      for (final entry in schedule) {
        final int no = (entry as Map)['no'] as int;
        _collapsed[_cardKey(loanType, no)] = true;
      }
    }
  }

  // ── Collapse helpers ──────────────────────────────────────────────────────

  String _cardKey(String loanType, int no) => '${loanType}_$no';
  String _allKey(String loanType)           => '${loanType}_all';

  bool _isCardCollapsed(String loanType, int no) =>
      _collapsed[_cardKey(loanType, no)] ?? false;

  bool _isAllCollapsed(String loanType) =>
      _collapsed[_allKey(loanType)] ?? false;

  void _toggleCard(String loanType, int no) {
    setState(() {
      final key = _cardKey(loanType, no);
      _collapsed[key] = !(_collapsed[key] ?? false);
    });
  }

  /// Collapse / expand all cards for a given loan at once.
  void _toggleAll(String loanType, List<dynamic> schedule) {
    setState(() {
      final allKey     = _allKey(loanType);
      final nowAll     = _collapsed[allKey] ?? false;
      final nextState  = !nowAll;
      _collapsed[allKey] = nextState;
      for (final entry in schedule) {
        final no = (entry as Map)['no'] as int;
        _collapsed[_cardKey(loanType, no)] = nextState;
      }
    });
  }

  // ─── Reusable option picker ───────────────────────────────────────────────

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
    backgroundColor: Colors.white,
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
            decoration: BoxDecoration(color: _grey300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor)),
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
                        ? Theme.of(context).primaryColor  // ← Solid background for white check
                        : Colors.transparent,
                    child: Row(
                      children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 14,
                                color: sel
                                    ? Colors
                                          .white 
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                fontWeight: sel
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
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

  // ─── Filter dialog ────────────────────────────────────────────────────────

 void _showFilterDialog() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    isScrollControlled: true, 
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.6,  
    ),  
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView( 
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                decoration: BoxDecoration(color: _grey300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Filter by Loan Type',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF587CA5)
                        : Theme.of(context).primaryColor)),
            const SizedBox(height: 14),
            Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _loanTypes.map((type) {
                final selected = _selectedLoanType == type;
                return Padding(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: double.infinity,  // ← Full width
                    child: ChoiceChip(
                      label: Center(child: Text(type)),  // ← Center type
                      selected: selected,
                      showCheckmark: false,  
                      onSelected: (_) {
                        setState(() {
                          _selectedLoanType = selected ? null : type;
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

  // ─── Loan details modal ───────────────────────────────────────────────────

  void _showLoanDetailsModal(Map<String, dynamic> loan) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor  = isDark ? _grey400 : _grey600;
    final Color divColor  = isDark ? _divDark : _divLight;
    final Color headerColor = isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;
    final status          = loan['loanStatus']?.toString() ?? 'N/A';

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.68),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: _grey300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.account_balance_outlined, color: headerColor, size: 18),
                const SizedBox(width: 8),
                Text('Loan Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: headerColor)),
                const Spacer(),
                _statusBadge(status, fontSize: 11),
              ],
            ),
            const SizedBox(height: 6),
            Divider(color: divColor),
            const SizedBox(height: 2),
            _detailRow('Loan Type',            loan['loanType'],                textColor, subColor),
            _detailRow('Loan Amount',          '₱${loan['loanAmount']}',        textColor, subColor),
            _detailRow('Interest Computation', loan['interestComputation'],     textColor, subColor),
            _detailRow('Interest',             loan['interest'],                textColor, subColor),
            _detailRow('Amortization Type',    loan['amortizationType'],        textColor, subColor),
            _detailRow('No. of Amortizations', '${loan['noOfAmortizations']}',  textColor, subColor),
            _detailRow('First Payment',        loan['firstPayment'],            textColor, subColor),
            _detailRow('Payment Progress',     loan['paymentProgress'],         textColor, subColor),
            const SizedBox(height: 8),
            Divider(color: divColor),
            const SizedBox(height: 4),
            _detailRow('Total Principal', '₱${loan['totalPrincipal']}', textColor, subColor),
            _detailRow('Total Interest',  '₱${loan['totalInterest']}',  textColor, subColor),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: headerColor)),
                Text('₱${loan['grandTotal']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: headerColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: subColor, fontWeight: FontWeight.w500)),
          Text(value ?? '—', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }

  // ─── Main build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLoanRecords,
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ]),
      );
    }

    return Column(
      children: [
        // ── Header bar ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('LOAN RECORDS',
                      style: TextStyle(color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  if (_selectedLoanType != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_selectedLoanType!,
                          style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      final target = _filteredRecords.isNotEmpty ? _filteredRecords.first : null;
                      if (target != null) _showLoanDetailsModal(target);
                    },
                    child: const Icon(Icons.account_balance_outlined, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Records ───────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.zero,
          child: _loanRecords.isEmpty
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No loan records available', style: TextStyle(fontSize: 16))))
              : _filteredRecords.isEmpty
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No records match the selected filter',
                          style: TextStyle(fontSize: 14))))
                  : Column(
                      children: _filteredRecords
                          .map((loan) => _buildLoanSection(loan))
                          .toList(),
                    ),
        ),
      ],
    );
  }

  // ─── Loan section ─────────────────────────────────────────────────────────

  Widget _buildLoanSection(Map<String, dynamic> loan) {
    final isDark          = Theme.of(context).brightness == Brightness.dark;
    final Color primary   = Theme.of(context).primaryColor;
    final Color subColor  = isDark ? _grey400 : _grey600;
    final Color divColor  = isDark ? _divDark : _divLight;
    final Color headerColor = isDark ? const Color(0xFF587CA5) : primary;
    final List<dynamic> schedule = (loan['schedule'] as List<dynamic>?) ?? [];
    final String loanType = loan['loanType'].toString();
    final bool allCollapsed = _isAllCollapsed(loanType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Loan header ───────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(Icons.account_balance, size: 18, color: isDark ? Colors.white70 : primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$loanType  •  ₱${loan['loanAmount']}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : primary),
                    ),
                    const SizedBox(height: 2),
                    Text(loan['paymentProgress'] ?? '',
                        style: TextStyle(fontSize: 11, color: subColor)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── "Amortization Schedule" sub-header with collapse-all toggle ──
        GestureDetector(
          onTap: () => _toggleAll(loanType, schedule),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 13, color: headerColor),
                const SizedBox(width: 4),
                Text('Amortization Schedule',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: headerColor, letterSpacing: 0.3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300], thickness: 1),
                ),
                const SizedBox(width: 6),
                // Collapse-all chevron
                Icon(
                  allCollapsed
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  size: 18,
                  color: headerColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),

        // ── One collapsible card per amortization entry ───────────────────
        ...schedule.map<Widget>((entry) {
          final e       = Map<String, dynamic>.from(entry as Map);
          final int no  = e['no'] as int;
          final bool collapsed = _isCardCollapsed(loanType, no);

          return _buildAmortCard(
            e:          e,
            loanType:   loanType,
            no:         no,
            collapsed:  collapsed,
            isDark:     isDark,
            divColor:   divColor,
            headerColor: headerColor,
          );
        }),

        // ── Totals footer ─────────────────────────────────────────────────
        _buildTotalsFooter(loan, isDark, divColor),

        const SizedBox(height: 20),
        Divider(color: divColor, thickness: 1.2, height: 1),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─── Collapsible amortization card ───────────────────────────────────────

  Widget _buildAmortCard({
    required Map<String, dynamic> e,
    required String loanType,
    required int no,
    required bool collapsed,
    required bool isDark,
    required Color divColor,
    required Color headerColor,
  }) {
    final Color primary   = Theme.of(context).primaryColor;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor  = isDark ? _grey400 : _grey600;
    final String status   = e['status']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // ── Card header — tap to toggle ───────────────────────────────
          GestureDetector(
            onTap: () => _toggleCard(loanType, no),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.event, size: 15, color: isDark ? Colors.white70 : primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e['date'] ?? '',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : primary),
                    ),
                  ),
                  _statusBadge(status, fontSize: 10),
                  const SizedBox(width: 8),
                  // Per-card chevron
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
          ),

          // ── Card body — hidden when collapsed ─────────────────────────
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                children: [
                  _amortRow(
                    icon: Icons.payments_outlined,
                    label: 'Principal',
                    value: e['principal'],
                    textColor: textColor,
                    subColor: subColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _amortRow(
                    icon: Icons.percent,
                    label: 'Interest',
                    value: e['interest'],
                    textColor: textColor,
                    subColor: subColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 0.8, color: divColor),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, size: 14,
                              color: isDark ? Colors.white70 : primary),
                          const SizedBox(width: 6),
                          Text('Total Payment',
                              style: TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w700, color: textColor)),
                        ],
                      ),
                      Text(
                        e['totalPayment'] != null ? '₱${e['totalPayment']}' : '—',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.bold, color: headerColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Divider between cards
          Divider(color: divColor, height: 1, thickness: 0.6),
        ],
      ),
    );
  }

  Widget _amortRow({
    required IconData icon,
    required String label,
    required dynamic value,
    required Color textColor,
    required Color subColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: subColor),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: subColor)),
          ],
        ),
        Text(
          value != null ? '₱${value.toString()}' : '—',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
        ),
      ],
    );
  }

  // ─── Totals footer ────────────────────────────────────────────────────────

  Widget _buildTotalsFooter(Map<String, dynamic> loan, bool isDark, Color divColor) {
    final Color headerColor = isDark ? const Color(0xFF587CA5) : Theme.of(context).primaryColor;
    final Color subColor    = isDark ? _grey400 : _grey600;
    final Color textColor   = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: divColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _totalCell('Total Principal', '₱${loan['totalPrincipal']}', subColor, textColor),
          Container(width: 1, height: 36, color: divColor),
          _totalCell('Total Interest', '₱${loan['totalInterest']}', subColor, textColor),
          Container(width: 1, height: 36, color: divColor),
          _totalCell('Grand Total', '₱${loan['grandTotal']}', subColor, headerColor),
        ],
      ),
    );
  }

  Widget _totalCell(String label, String value, Color subColor, Color valueColor) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, color: subColor)),
      ],
    );
  }

  // ─── Status badge ─────────────────────────────────────────────────────────

  Widget _statusBadge(String status, {double fontSize = 11}) {
    final Color c = _statusColorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: c)),
    );
  }

  Color _statusColorOf(String status) {
    switch (status.toLowerCase()) {
      case 'paid':    return _paidColor;
      case 'active':  return _activeColor;
      case 'pending': return _pendingColor;
      default:        return _grey600;
    }
  }
}