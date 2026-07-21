import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:traqio/core/theme/app_spacing.dart';
import 'package:traqio/core/enums/payment_method.dart';
import 'package:traqio/features/payments/presentation/providers/payment_providers.dart';
import 'package:traqio/features/payments/presentation/widgets/payment_type_badge.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final String paymentId;
  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final paymentAsync = ref.watch(paymentDetailProvider(paymentId));
    final currency = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM y, h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: paymentAsync.whenOrNull(data: (p) => Text(p.paymentNumber)) ?? const Text('Payment'),
      ),
      body: SafeArea(
        child: paymentAsync.when(
          data: (payment) => ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PaymentTypeBadge(type: payment.paymentType),
                  Text(currency.format(payment.amount), style: theme.textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _InfoRow(label: 'Party', value: payment.counterpartyName),
              _InfoRow(label: 'Payment date', value: dateFormat.format(payment.paymentDate)),
              if (payment.paymentMethod != null)
                _InfoRow(label: 'Method', value: payment.paymentMethod!.label),
              if (payment.paymentReference != null && payment.paymentReference!.isNotEmpty)
                _InfoRow(label: 'Reference', value: payment.paymentReference!),
              if (payment.invoiceNumber != null)
                _InfoRow(label: 'Invoice', value: payment.invoiceNumber!),
              _InfoRow(label: 'Recorded', value: dateFormat.format(payment.createdAt)),
              if (payment.notes != null && payment.notes!.isNotEmpty)
                _InfoRow(label: 'Notes', value: payment.notes!),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Could not load payment: $e')),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
