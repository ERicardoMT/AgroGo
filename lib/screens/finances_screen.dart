import 'package:flutter/material.dart';
import '../globals.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';
import '../models/bank_account.dart';
import '../data/database_helper.dart'; // <-- IMPORT MBD
import 'banking_details_screen.dart';
import 'landlord_profile_screen.dart';
import 'notifications_screen.dart'; // <-- IMPORT BANKING DETAILS SCREEN TO NAVIGATE

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Transaction> transactions = [];
  List<BankAccount> bankAccounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    _loadMockData(); // Cargamos transacciones de mentira
    await _loadRealBankAccounts(); // Cargamos cuentas bancarias de la BD
    setState(() {
      isLoading = false; // Detenemos la carga y dibujamos la pantalla
    });
  }

  Future<void> _loadRealBankAccounts() async {
    final dbHelper = DatabaseHelper();
    final allAccounts = await dbHelper.getAll('bank_accounts');
    final currentEmail = currentUserEmailNotifier.value;

    bankAccounts = []; // Limpiamos la lista

    if (currentEmail != null && allAccounts.isNotEmpty) {
      try {
        final miCuentaData = allAccounts.firstWhere(
          (acc) => acc['id'] == "bank_$currentEmail",
        );

        bankAccounts.add(
          BankAccount(
            id: miCuentaData['id'].toString(),
            accountHolder: miCuentaData['accountHolder'].toString(),
            bankName: miCuentaData['bankName'].toString(),
            accountNumber: miCuentaData['accountNumber'].toString(),
            accountType: miCuentaData['accountType'].toString(),
            swiftCode: miCuentaData['swiftCode']?.toString(),
            iban: miCuentaData['iban']?.toString(),
            isDefault: miCuentaData['isDefault'] == 1,
            createdAt:
                DateTime.tryParse(miCuentaData['createdAt'].toString()) ??
                DateTime.now(),
          ),
        );
      } catch (e) {
        // El usuario no tiene cuenta registrada
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    transactions = [];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          tr('Finanzas y Pagos', 'Finances and Payments'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: isDark ? Colors.grey[600] : Colors.grey[700],
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Tab(
              text: tr('Transacciones', 'Transactions'),
              icon: const Icon(Icons.history_rounded),
            ),
            Tab(
              text: tr('Métodos Retiro', 'Withdrawal Methods'),
              icon: const Icon(Icons.account_balance_rounded),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(isDark),
          _buildWithdrawalMethodsTab(isDark),
        ],
      ),
    );
  }

  // ========== TAB 1: HISTORIAL DE TRANSACCIONES ==========
  Widget _buildTransactionsTab(bool isDark) {
    final completedTransactions =
        transactions.where((t) => t.status == 'completed').toList()
          ..sort((a, b) => b.completedDate!.compareTo(a.completedDate!));

    if (completedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              tr('Sin transacciones completadas', 'No completed transactions'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: completedTransactions.length,
      itemBuilder: (context, index) =>
          _buildTransactionCard(completedTransactions[index], isDark),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.equipmentName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cliente: ${transaction.renterName}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr('Completada', 'Completed'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${transaction.completedDate?.day}/${transaction.completedDate?.month}/${transaction.completedDate?.year}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(isDark ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('Monto Total:', 'Total Amount:'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '\$${transaction.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('Comisión App (10%):', 'App Commission (10%):'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '-\$${transaction.appCommission.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  height: 1,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr('Ganancia Neta:', 'Net Profit:'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${transaction.netProfit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (transaction.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              transaction.notes!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========== TAB 2: MÉTODOS DE RETIRO ==========
  Widget _buildWithdrawalMethodsTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        // Resumen de saldo
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Saldo Disponible', 'Available Balance'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$2,750.50',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('Listo para retirar', 'Ready to withdraw'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tr('Retiro iniciado', 'Withdrawal started')),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_downward_rounded),
              label: Text(tr('Retirar', 'Withdraw')),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                // Al volver, recargamos la info por si agregó cuenta
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BankingDetailsScreen(),
                  ),
                );
                setState(() {
                  isLoading = true;
                });
                await _loadRealBankAccounts();
                setState(() {
                  isLoading = false;
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(tr('Agregar Método', 'Add Method')),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          tr('Cuentas Bancarias Configuradas', 'Configured Bank Accounts'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        if (bankAccounts.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                tr('Sin cuentas configuradas', 'No configured accounts'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          )
        else
          Column(
            children: bankAccounts
                .map((account) => _buildBankAccountCard(account, isDark))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildBankAccountCard(BankAccount account, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF303030) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.bankName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.maskedAccountNumber,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (account.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tr('Predeterminada', 'Default'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('Tipo de Cuenta:', 'Account Type:'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.accountType,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr('Titular:', 'Holder:'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.accountHolder,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BankingDetailsScreen(),
                      ),
                    );
                    setState(() {
                      isLoading = true;
                    });
                    await _loadRealBankAccounts();
                    setState(() {
                      isLoading = false;
                    });
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    tr('Editar', 'Edit'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          tr('Cuenta eliminada', 'Account deleted'),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(
                    tr('Eliminar', 'Delete'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddBankAccountDialog(bool isDark) {
    final bankNameController = TextEditingController();
    final accountHolderController = TextEditingController();
    final accountNumberController = TextEditingController();
    final swiftCodeController = TextEditingController();
    String selectedAccountType = 'Checking';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(tr('Agregar Cuenta Bancaria', 'Add Bank Account')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameController,
                decoration: InputDecoration(
                  labelText: tr('Nombre del Banco', 'Bank Name'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountHolderController,
                decoration: InputDecoration(
                  labelText: tr('Titular de la Cuenta', 'Account Holder'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedAccountType,
                decoration: InputDecoration(
                  labelText: tr('Tipo de Cuenta', 'Account Type'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: ['Checking', 'Savings', 'Business']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  selectedAccountType = value ?? 'Checking';
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountNumberController,
                decoration: InputDecoration(
                  labelText: tr('Número de Cuenta', 'Account Number'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: swiftCodeController,
                decoration: InputDecoration(
                  labelText: tr('Código SWIFT', 'SWIFT Code'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintText: 'Opcional / Optional',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('Cancelar', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (bankNameController.text.isNotEmpty &&
                  accountHolderController.text.isNotEmpty &&
                  accountNumberController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Cuenta agregada exitosamente',
                        'Account added successfully',
                      ),
                    ),
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tr(
                        'Completa todos los campos requeridos',
                        'Complete all required fields',
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(tr('Agregar', 'Add')),
          ),
        ],
      ),
    );
  }
}
