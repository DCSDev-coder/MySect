class Transaction {
  final String title;
  final DateTime date;
  final bool documentsNeeded;
  final bool replyNeeded;
  final bool isTransaction;

  Transaction({
    required this.title,
    required this.date,
    this.documentsNeeded = false,
    this.replyNeeded = false,
    this.isTransaction = false,
  });
}

List<Transaction> get allTransactions => [
  Transaction(title: 'Transaction_Doc_A.pdf', date: DateTime(2026, 9, 15), documentsNeeded: true, isTransaction: true),
  Transaction(title: 'Transaction_Doc_B.pdf', date: DateTime(2026, 9, 12), replyNeeded: true, isTransaction: true),
  Transaction(title: 'Missing_Signature.pdf', date: DateTime(2026, 9, 10), documentsNeeded: true, isTransaction: true),
  Transaction(title: '5LUXE Scents Pted. Ltd. - UFS for 2026', date: DateTime(2026, 9, 14), documentsNeeded: true),
  Transaction(title: 'Pending Invoices Q3', date: DateTime(2026, 9, 13), documentsNeeded: true),
  Transaction(title: 'Board Meeting Minutes', date: DateTime(2026, 9, 11), documentsNeeded: true),
  Transaction(title: 'Notice of Assessment 2026', date: DateTime(2026, 9, 9), documentsNeeded: true),
  Transaction(title: 'Rental Agreement', date: DateTime(2026, 9, 8), documentsNeeded: true),
  Transaction(title: 'Office Lease Agreement', date: DateTime(2026, 9, 7), documentsNeeded: true),
  Transaction(title: 'Non-Disclosure Agreement', date: DateTime(2026, 9, 5), documentsNeeded: true),
];

int get documentsNeededCount => allTransactions.where((t) => t.documentsNeeded).length;
int get replyNeededCount => allTransactions.where((t) => t.replyNeeded).length;

int get transactionDocsNeededCount => allTransactions.where((t) => t.documentsNeeded && t.isTransaction).length;
int get transactionReplyNeededCount => allTransactions.where((t) => t.replyNeeded && t.isTransaction).length;
