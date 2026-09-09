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

final List<Transaction> allTransactions = [
  Transaction(title: 'Transaction_Doc_A.pdf', date: DateTime(2024, 3, 15), documentsNeeded: true, isTransaction: true),
  Transaction(title: 'Transaction_Doc_B.pdf', date: DateTime(2024, 3, 12), replyNeeded: true, isTransaction: true),
  Transaction(title: 'Missing_Signature.pdf', date: DateTime(2024, 3, 10), documentsNeeded: true, isTransaction: true),
  Transaction(title: '5LUXE Scents Pted. Ltd. - UFS for 2024', date: DateTime(2024, 3, 14), documentsNeeded: true),
  Transaction(title: 'Pending Invoices Q4', date: DateTime(2024, 3, 13), documentsNeeded: true),
  Transaction(title: 'Board Meeting Minutes', date: DateTime(2024, 3, 11), documentsNeeded: true),
  Transaction(title: 'Notice of Assessment 2023', date: DateTime(2024, 3, 9), documentsNeeded: true),
  Transaction(title: 'Rental Agreement', date: DateTime(2024, 3, 8), documentsNeeded: true),
  Transaction(title: 'Office Lease Agreement', date: DateTime(2024, 3, 7), documentsNeeded: true),
  Transaction(title: 'Non-Disclosure Agreement', date: DateTime(2024, 3, 5), documentsNeeded: true),
];

final int documentsNeededCount = allTransactions.where((t) => t.documentsNeeded).length;
final int replyNeededCount = allTransactions.where((t) => t.replyNeeded).length;

final int transactionDocsNeededCount = allTransactions.where((t) => t.documentsNeeded && t.isTransaction).length;
final int transactionReplyNeededCount = allTransactions.where((t) => t.replyNeeded && t.isTransaction).length;
